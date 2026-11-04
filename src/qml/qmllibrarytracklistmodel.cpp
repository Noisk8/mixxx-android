#include "qml/qmllibrarytracklistmodel.h"

#include <qnamespace.h>

#include <QAbstractProxyModel>
#include <QObject>
#include <QQmlEngine>
#include <QSortFilterProxyModel>
#include <QStandardItemModel>
#include <QVariant>

#include "library/basetracktablemodel.h"
#include "library/browse/browsetablemodel.h"
#include "library/columncache.h"
#include "moc_qmllibrarytracklistmodel.cpp"
#include "qml/asyncimageprovider.h"
#include "qml/qmllibrarytracklistcolumn.h"
#include "qml_owned_ptr.h"
#include "qmltrackproxy.h"
#include "track/track.h"
#include "util/assert.h"
#include "util/parented_ptr.h"

namespace mixxx {
namespace qml {
namespace {
const QHash<int, QByteArray> kRoleNames = {
        {Qt::DisplayRole, "display"},
        {Qt::DecorationRole, "decoration"},
        {QmlLibraryTrackListModel::Delegate, "delegate"},
        {QmlLibraryTrackListModel::Track, "track"},
        {QmlLibraryTrackListModel::FileURL, "file_url"},
        {QmlLibraryTrackListModel::CoverArt, "cover_art"},
};

QColor colorFromRgbCode(double colorValue) {
    if (colorValue < 0 || colorValue > 0xFFFFFF) {
        return {};
    }

    QRgb rgbValue = static_cast<QRgb>(colorValue) | 0xFF000000;
    return QColor(rgbValue);
}

/// The folder browser has its own fixed columns
int browseColumn(int column) {
    switch (static_cast<ColumnCache::Column>(column)) {
    case ColumnCache::COLUMN_LIBRARYTABLE_ALBUM:
        return COLUMN_ALBUM;
    case ColumnCache::COLUMN_LIBRARYTABLE_ARTIST:
        return COLUMN_ARTIST;
    case ColumnCache::COLUMN_LIBRARYTABLE_TITLE:
        return COLUMN_TITLE;
    case ColumnCache::COLUMN_LIBRARYTABLE_YEAR:
        return COLUMN_YEAR;
    case ColumnCache::COLUMN_LIBRARYTABLE_BPM:
        return COLUMN_BPM;
    case ColumnCache::COLUMN_LIBRARYTABLE_KEY:
        return COLUMN_KEY;
    case ColumnCache::COLUMN_LIBRARYTABLE_FILETYPE:
        return COLUMN_TYPE;
    case ColumnCache::COLUMN_LIBRARYTABLE_BITRATE:
        return COLUMN_BITRATE;
    // Folders have no "date added", the time the file was last modified
    // takes its place
    case ColumnCache::COLUMN_LIBRARYTABLE_DATETIMEADDED:
        return COLUMN_FILE_MODIFIED_TIME;
    default:
        return column;
    }
}
} // namespace

int QmlLibraryTrackListModel::sourceColumn(int column) const {
    if (column < 0) {
        return column;
    }
    if (auto* const pTrackTableModel = qobject_cast<BaseTrackTableModel*>(sourceModel())) {
        return pTrackTableModel->fieldIndex(static_cast<ColumnCache::Column>(column));
    }
    // The folder browser is wrapped in a ProxyTrackModel, which keeps the
    // columns of its source
    QAbstractItemModel* pModel = sourceModel();
    while (auto* const pProxyModel = qobject_cast<QAbstractProxyModel*>(pModel)) {
        pModel = pProxyModel->sourceModel();
    }
    if (qobject_cast<BrowseTableModel*>(pModel)) {
        return browseColumn(column);
    }
    return column;
}

QmlLibraryTrackListModel::QmlLibraryTrackListModel(
        const QList<QmlLibraryTrackListColumn*>& librarySource,
        QAbstractItemModel* pModel,
        QObject* pParent)
        : QIdentityProxyModel(pParent),
          m_columns() {
    m_columns.reserve(librarySource.size());
    for (const auto* pColumn : std::as_const(librarySource)) {
        m_columns.emplace_back(make_parented<QmlLibraryTrackListColumn>(this,
                pColumn->label(),
                pColumn->fillSpan(),
                pColumn->columnIdx(),
                pColumn->preferredWidth(),
                pColumn->autoHideWidth(),
                pColumn->delegate(),
                pColumn->role()));
    }

    auto* pTrackModel = dynamic_cast<TrackModel*>(pModel);
    VERIFY_OR_DEBUG_ASSERT(pTrackModel) {
        return;
    }
    pTrackModel->select();
    setSourceModel(pModel);
}

QVariant QmlLibraryTrackListModel::data(const QModelIndex& proxyIndex, int role) const {
    if (!proxyIndex.isValid()) {
        return {};
    }

    VERIFY_OR_DEBUG_ASSERT(checkIndex(proxyIndex)) {
        return {};
    }
    auto columnIdx = proxyIndex.column();
    VERIFY_OR_DEBUG_ASSERT(columnIdx >= 0 || columnIdx < m_columns.size()) {
        return {};
    }

    auto* const pTrackTableModel = qobject_cast<BaseTrackTableModel*>(sourceModel());
    auto* const pTrackModel = dynamic_cast<TrackModel*>(sourceModel());

    const auto& pColumn = m_columns[columnIdx];

    switch (role) {
    case Track: {
        // Getting a track from the folder browser adds it to the library
        if (pTrackTableModel == nullptr) {
            return {};
        }
        auto pTrack = make_qml_owned<QmlTrackProxy>(pTrackModel->getTrack(
                QIdentityProxyModel::mapToSource(proxyIndex)));
        return QVariant::fromValue(pTrack.get());
    }
    case Qt::DecorationRole: {
        if (pTrackTableModel == nullptr) {
            return {};
        };
        return colorFromRgbCode(QIdentityProxyModel::data(
                proxyIndex.siblingAtColumn(pTrackTableModel->fieldIndex(
                        ColumnCache::COLUMN_LIBRARYTABLE_COLOR)),
                Qt::DisplayRole)
                        .toDouble());
    }
    case CoverArt: {
        QString location;
        if (pTrackTableModel != nullptr) {
            location = QIdentityProxyModel::data(
                    proxyIndex.siblingAtColumn(pTrackTableModel->fieldIndex(
                            ColumnCache::COLUMN_TRACKLOCATIONSTABLE_LOCATION)),
                    Qt::DisplayRole)
                               .toString();
        }
        if (location.isEmpty()) {
            return {};
        }

        return AsyncImageProvider::trackLocationToCoverArtUrl(location);
    }
    case FileURL: {
        if (pTrackModel == nullptr) {
            return {};
        }
        return pTrackModel->getTrackUrl(QIdentityProxyModel::mapToSource(proxyIndex));
    }
    case Delegate:
        return QVariant::fromValue(pColumn->delegate());
        break;
    }
    if (pColumn->columnIdx() < 0) {
        // Use proxyIndex.column()
        return QIdentityProxyModel::data(proxyIndex, role);
    }
    return QIdentityProxyModel::data(
            proxyIndex.siblingAtColumn(sourceColumn(pColumn->columnIdx())), role);
}

int QmlLibraryTrackListModel::columnCount(const QModelIndex& parent) const {
    VERIFY_OR_DEBUG_ASSERT(static_cast<QmlLibraryTrackListModel*>(
                                   parent.internalPointer()) != this) {
        return 0;
    }
    return m_columns.size();
}

QVariant QmlLibraryTrackListModel::headerData(
        int section, Qt::Orientation orientation, int role) const {
    VERIFY_OR_DEBUG_ASSERT(section >= 0 || section < m_columns.size()) {
        return {};
    }
    // TODO role
    return m_columns[section]->label();
}

QHash<int, QByteArray> QmlLibraryTrackListModel::roleNames() const {
    return kRoleNames;
}

QUrl QmlLibraryTrackListModel::getUrl(int row) const {
    auto* const pTrackModel = dynamic_cast<TrackModel*>(sourceModel());

    if (pTrackModel == nullptr) {
        // TODO search for column with role
        return {};
    }
    return pTrackModel->getTrackUrl(sourceModel()->index(row, 0));
}

QmlTrackProxy* QmlLibraryTrackListModel::getTrack(int row) const {
    auto* const pTrackModel = dynamic_cast<TrackModel*>(sourceModel());

    if (pTrackModel == nullptr) {
        // TODO search for column with role
        return {};
    }
    return make_qml_owned<QmlTrackProxy>(pTrackModel->getTrack(sourceModel()->index(row, 0)));
}

TrackModel::Capabilities QmlLibraryTrackListModel::getCapabilities() const {
    auto* const pTrackModel = dynamic_cast<TrackModel*>(sourceModel());

    if (pTrackModel != nullptr) {
        return pTrackModel->getCapabilities();
    }
    return TrackModel::Capability::None;
}
bool QmlLibraryTrackListModel::hasCapabilities(TrackModel::Capabilities caps) const {
    return (getCapabilities() & caps) == caps;
}

void QmlLibraryTrackListModel::search(const QString& searchText) {
    auto* const pTrackModel = dynamic_cast<TrackModel*>(sourceModel());
    VERIFY_OR_DEBUG_ASSERT(pTrackModel) {
        return;
    }
    pTrackModel->search(searchText);
}

void QmlLibraryTrackListModel::sort(int column, Qt::SortOrder order) {
    VERIFY_OR_DEBUG_ASSERT(column >= 0 || column < m_columns.size()) {
        return;
    }
    const auto& pColumn = m_columns[column];
    emit layoutAboutToBeChanged(QList<QPersistentModelIndex>(),
            QAbstractItemModel::VerticalSortHint);
    if (pColumn->columnIdx() < 0) {
        // Use proxyIndex.column()
        return sourceModel()->sort(column, order);
    }
    sourceModel()->sort(sourceColumn(pColumn->columnIdx()), order);
    emit layoutChanged(QList<QPersistentModelIndex>(), QAbstractItemModel::VerticalSortHint);
}

} // namespace qml
} // namespace mixxx

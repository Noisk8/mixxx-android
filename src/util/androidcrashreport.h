#pragma once

#include <QString>

namespace mixxx {
namespace android {

/// Diagnostics for crashes on Android, where the log in the app's private
/// folder can't be reached without a computer.

/// The folder the crash reports and the previous log are written to,
/// /storage/emulated/0/Mixxx/logs
QString crashReportDirectory();

/// Writes a short report with the call stack of the crashing thread to
/// crashReportDirectory() when Mixxx crashes (crash-<time>.txt). The
/// addresses are given as library + offset, which can be resolved with the
/// unstripped libraries of the same build. The system's crash handler runs
/// afterwards as before.
void installCrashReporter();

/// Copies the log of the previous run (mixxx.log.1 after the rotation) to
/// crashReportDirectory()/mixxx-previous.log
void exportPreviousLog(const QString& logDirPath);

} // namespace android
} // namespace mixxx

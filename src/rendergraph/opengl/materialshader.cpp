#include "rendergraph/materialshader.h"

#include <QFile>
#include <QOpenGLContext>
#ifdef USE_QSHADER_FOR_GL
#include <rhi/qshader.h>
#endif

#include "../../util/assert.h"

using namespace rendergraph;

namespace {
#ifdef USE_QSHADER_FOR_GL
QString resource(const QString& filename) {
    return QStringLiteral(":/shaders/rendergraph/%1.qsb").arg(filename);
}

QByteArray loadShaderCodeFromFile(const QString& path) {
    QFile file(path);
    if (!file.open(QIODeviceBase::ReadOnly)) {
        qWarning() << "Failed to open the shader file:" << path;
        return QByteArray();
    }
    const QShader qsbShader = QShader::fromSerialized(file.readAll());

    // The qsb bundles carry several GLSL variants (see shaders/CMakeLists.txt).
    // Desktop drivers accept the legacy '#version 120' output, but OpenGL ES
    // drivers (Android Mali/Adreno) reject it outright; they need the
    // '#version 300 es' variant which keeps the interface block syntax.
#ifdef Q_OS_ANDROID
    // Android is always OpenGL ES even if the shader is compiled before a
    // context becomes current.
    const bool isGles = true;
#else
    const QOpenGLContext* pContext = QOpenGLContext::currentContext();
    const bool isGles = pContext && pContext->isOpenGLES();
#endif
    if (isGles) {
        const QShaderKey esKey(
                QShader::GlslShader, QShaderVersion(300, QShaderVersion::GlslEs));
        const QByteArray esCode = qsbShader.shader(esKey).shader();
        if (!esCode.isEmpty()) {
            return esCode;
        }
        qWarning().noquote()
                << "MaterialShader: no GLSL ES 3.0 variant in" << path
                << "- falling back to desktop GLSL";
    }
    QShaderKey key(QShader::GlslShader, 120);
    return qsbShader.shader(key).shader();
}
#else
QString resource(const QString& filename) {
    return QStringLiteral(":/shaders/rendergraph/%1.gl").arg(filename);
}

QByteArray loadShaderCodeFromFile(const QString& path) {
    QFile file(path);
    if (!file.open(QIODeviceBase::ReadOnly)) {
        qWarning() << "Failed to open shader file:" << path;
        return QByteArray();
    }
    return file.readAll();
}
#endif
} // namespace

MaterialShader::MaterialShader(const char* vertexShaderFilename,
        const char* fragmentShaderFilename,
        const UniformSet& uniformSet,
        const AttributeSet& attributeSet) {
    const QString vertexShaderFileFullPath = resource(vertexShaderFilename);
    const QString fragmentShaderFileFullPath = resource(fragmentShaderFilename);

    QByteArray vertexCode = loadShaderCodeFromFile(vertexShaderFileFullPath);
    QByteArray fragmentCode = loadShaderCodeFromFile(fragmentShaderFileFullPath);
    VERIFY_OR_DEBUG_ASSERT(!vertexCode.isEmpty() && !fragmentCode.isEmpty()) {
        return;
    }
    if (!addShaderFromSourceCode(QOpenGLShader::Vertex, vertexCode)) {
        qWarning() << "MaterialShader - compilation failed:"
                   << vertexShaderFileFullPath;
        qDebug() << log();
        return;
    }

    if (!addShaderFromSourceCode(QOpenGLShader::Fragment, fragmentCode)) {
        qWarning() << "MaterialShader - compilation failed:"
                   << fragmentShaderFileFullPath;
        qDebug() << log();
        return;
    }

    if (!link()) {
        qDebug() << "MaterialShader - linking failed."
                 << log();
        return;
    }

    for (const auto& attribute : attributeSet.attributes()) {
        int location = QOpenGLShaderProgram::attributeLocation(attribute.m_name);
        m_attributeLocations.push_back(location);
    }
    for (const auto& uniform : uniformSet.uniforms()) {
        int location = QOpenGLShaderProgram::uniformLocation(uniform.m_name);
        m_uniformLocations.push_back(location);
    }
}

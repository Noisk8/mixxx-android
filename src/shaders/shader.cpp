#include "shaders/shader.h"

#include <QOpenGLContext>

#include "util/assert.h"

using namespace mixxx;

#ifdef MIXXX_USE_QOPENGL
using GLShader = QOpenGLShader;
#else
using GLShader = QGLShader;
#endif

namespace {
// The legacy shader sources below are plain desktop GLSL ('#version 120' or
// no version at all). OpenGL ES drivers (Android) reject the desktop version
// directive and GLSL ES 1.00 fragment shaders require an explicit default
// float precision, so transform the sources on GLES contexts.
QString adaptSourceForGles(const QString& code, bool isFragment) {
    QString result = code;
    if (result.contains(QLatin1String("#version 120"))) {
        result.replace(QLatin1String("#version 120"), QLatin1String("#version 100"));
    } else {
        result.prepend(QLatin1String("#version 100\n"));
    }
    if (isFragment && !result.contains(QLatin1String("precision"))) {
        const int versionEnd = result.indexOf(QLatin1Char('\n'));
        result.insert(versionEnd + 1,
                QStringLiteral("\nprecision highp float;\nprecision highp int;\n"));
    }
    return result;
}

bool currentContextIsGles() {
#ifdef Q_OS_ANDROID
    return true;
#else
    const QOpenGLContext* pContext = QOpenGLContext::currentContext();
    return pContext && pContext->isOpenGLES();
#endif
}
} // namespace

Shader::Shader() = default;

Shader::~Shader() = default;

void Shader::load(const QString& vertexShaderCode, const QString& fragmentShaderCode) {
    const bool isGles = currentContextIsGles();
    const QString vertexCode =
            isGles ? adaptSourceForGles(vertexShaderCode, false) : vertexShaderCode;
    const QString fragmentCode =
            isGles ? adaptSourceForGles(fragmentShaderCode, true) : fragmentShaderCode;

    VERIFY_OR_DEBUG_ASSERT(addShaderFromSourceCode(
            GLShader::Vertex, vertexCode)) {
        return;
    }

    VERIFY_OR_DEBUG_ASSERT(addShaderFromSourceCode(
            GLShader::Fragment, fragmentCode)) {
        return;
    }

    VERIFY_OR_DEBUG_ASSERT(link()) {
        return;
    }
}

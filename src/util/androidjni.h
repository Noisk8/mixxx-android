#pragma once

#if defined(Q_OS_ANDROID)
#include <QtCore/qcoreapplication_platform.h>
#include <android/log.h>
#include <QJniEnvironment>
#include <QJniObject>
#include <utility>

namespace mixxx {
namespace android {

/// Helper that checks and clears any pending JNI exceptions so that
/// unexpected Java-side exceptions or missing services degrade gracefully
/// rather than terminating the process with an ART abort.
class SafeJni {
  public:
    static bool checkException(const char* contextTag = nullptr) {
        QJniEnvironment env;
        if (env.isValid() && env->ExceptionCheck()) {
            __android_log_print(ANDROID_LOG_ERROR,
                    "MixxxJNI",
                    "Java exception detected in context [%s]. Clearing exception.",
                    contextTag != nullptr ? contextTag : "unknown");
            env->ExceptionDescribe();
            env->ExceptionClear();
            return true;
        }
        return false;
    }

    template <typename Ret, typename... Args>
    static Ret callStaticMethod(const char* className,
            const char* methodName,
            const char* signature,
            Args&&... args) {
        checkException("pre-call");
        Ret res = QJniObject::callStaticMethod<Ret>(className,
                methodName,
                signature,
                std::forward<Args>(args)...);
        checkException(className);
        return res;
    }

    template <typename... Args>
    static void callStaticVoidMethod(const char* className,
            const char* methodName,
            const char* signature,
            Args&&... args) {
        checkException("pre-call");
        QJniObject::callStaticMethod<void>(className,
                methodName,
                signature,
                std::forward<Args>(args)...);
        checkException(className);
    }

    template <typename... Args>
    static QJniObject callStaticObjectMethod(const char* className,
            const char* methodName,
            const char* signature,
            Args&&... args) {
        checkException("pre-call");
        QJniObject res = QJniObject::callStaticObjectMethod(className,
                methodName,
                signature,
                std::forward<Args>(args)...);
        checkException(className);
        return res;
    }
};

} // namespace android
} // namespace mixxx
#endif

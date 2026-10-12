#pragma once

#include <QJniObject>
#include <QString>
#include <condition_variable>
#include <mutex>
#include <vector>

struct libusb_context;

namespace mixxx {
namespace android {

const QJniObject& getIntent();
bool waitForPermission(const QJniObject& device);
void usbDeviceAccessResult(QJniObject device, bool granted);

extern std::mutex s_androidLock;
extern std::condition_variable s_grantingWaitCond;
extern std::vector<std::pair<QString, bool>> s_grantingResult;
extern QJniObject s_intent;
extern QJniObject s_usbManager;

} // namespace android
} // namespace mixxx

#include <gtest/gtest.h>

#include <string>
#include <vector>

#include "soundio/androidusbremap.h"

namespace {
struct FakeDeviceId {
    std::string name;
    int deviceIndex;

    bool operator==(const FakeDeviceId& other) const {
        return name == other.name && deviceIndex == other.deviceIndex;
    }
};
} // namespace

using mixxx::android::resolveRecoveredDeviceId;

TEST(AndroidUsbRemapTest, KeepsSavedIdWhenNothingMatches) {
    const FakeDeviceId saved{"DDJ-400", 3};
    EXPECT_EQ(saved, resolveRecoveredDeviceId(saved, {}));
    EXPECT_EQ(saved, resolveRecoveredDeviceId(saved, {{"Speaker", 0}}));
}

TEST(AndroidUsbRemapTest, UsesNewIndexWhenDeviceReturnsUniquely) {
    const FakeDeviceId saved{"DDJ-400", 3};
    const std::vector<FakeDeviceId> available{{"Speaker", 0}, {"DDJ-400", 7}};
    EXPECT_EQ((FakeDeviceId{"DDJ-400", 7}), resolveRecoveredDeviceId(saved, available));
}

TEST(AndroidUsbRemapTest, KeepsSavedIdWhenNameIsAmbiguous) {
    const FakeDeviceId saved{"DDJ-400", 3};
    const std::vector<FakeDeviceId> available{{"DDJ-400", 7}, {"DDJ-400", 8}};
    EXPECT_EQ(saved, resolveRecoveredDeviceId(saved, available));
}

TEST(AndroidUsbRemapTest, MatchesNameExactly) {
    const FakeDeviceId saved{"DDJ-400", 3};
    const std::vector<FakeDeviceId> available{{"DDJ-4000", 7}, {"ddj-400", 8}};
    EXPECT_EQ(saved, resolveRecoveredDeviceId(saved, available));
}

TEST(AndroidUsbRemapTest, TwentyReplugCyclesRestoreTheSameDevice) {
    FakeDeviceId saved{"DDJ-400", 3};
    for (int cycle = 1; cycle <= 20; ++cycle) {
        const FakeDeviceId replugged{"DDJ-400", 3 + cycle};
        saved = resolveRecoveredDeviceId(saved, {{"Speaker", 0}, replugged});
        EXPECT_EQ(replugged, saved) << "cycle " << cycle;
    }
}

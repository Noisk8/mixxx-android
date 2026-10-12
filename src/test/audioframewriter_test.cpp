#include <gtest/gtest.h>

#include <vector>
#include "soundio/audioframewriter.h"

using mixxx::audio::WriteResult;
using mixxx::audio::writeFrames;

TEST(AudioFrameWriterTest, PartialWritesKeepFrameOrder) {
    std::vector<int> offsets;
    std::vector<int> sizes;
    EXPECT_EQ(WriteResult::Complete, writeFrames(64, 16, [] { return true; },
            [&](int offset, int size) { offsets.push_back(offset); sizes.push_back(size); return 16; }));
    EXPECT_EQ((std::vector<int>{0, 16, 32, 48}), offsets);
    EXPECT_EQ((std::vector<int>{64, 48, 32, 16}), sizes);
}

TEST(AudioFrameWriterTest, DeadOutputStopsWithoutRetry) {
    int calls = 0;
    EXPECT_EQ(WriteResult::Error, writeFrames(64, 16, [] { return true; },
            [&](int, int) { ++calls; return -6; }));
    EXPECT_EQ(1, calls);
}

TEST(AudioFrameWriterTest, RejectsStalledMisalignedAndOversizedWrites) {
    for (int written : {0, 15, 65, 80}) {
        EXPECT_EQ(WriteResult::Error, writeFrames(64, 16, [] { return true; },
                [written](int, int) { return written; }));
    }
}

TEST(AudioFrameWriterTest, CloseUnblocksWriteWithoutRecoveryAlarm) {
    bool active = true;
    EXPECT_EQ(WriteResult::Cancelled, writeFrames(64, 16, [&] { return active; },
            [&](int, int) { active = false; return 0; }));
}

TEST(AudioFrameWriterTest, CancelledOutputDoesNotWrite) {
    EXPECT_EQ(WriteResult::Cancelled, writeFrames(64, 16, [] { return false; },
            [](int, int) { ADD_FAILURE(); return 16; }));
}

TEST(AudioFrameWriterTest, RejectsInvalidBufferBeforeWrite) {
    for (int bytes : {0, -1, 15, 17}) {
        EXPECT_EQ(WriteResult::Error, writeFrames(bytes, 16, [] { return true; },
                [](int, int) { ADD_FAILURE(); return 16; }));
    }
}

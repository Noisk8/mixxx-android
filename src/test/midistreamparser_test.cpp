#include "controllers/midi/midistreamparser.h"

#include <gtest/gtest.h>

#include <vector>

namespace mixxx {
namespace {
using Type = MidiStreamParser::MessageType;

TEST(MidiStreamParserTest, RunningStatusAndRealtimeAcrossChunks) {
    MidiStreamParser parser;
    EXPECT_EQ(Type::None, parser.processByte(0x90).type);
    EXPECT_EQ(Type::None, parser.processByte(0x40).type);
    const auto clock = parser.processByte(0xF8);
    EXPECT_EQ(Type::Short, clock.type);
    EXPECT_EQ(0xF8, clock.status);
    const auto first = parser.processByte(0x7F);
    EXPECT_EQ(Type::Short, first.type);
    EXPECT_EQ(0x90, first.status);
    EXPECT_EQ(0x40, first.data1);
    EXPECT_EQ(0x7F, first.data2);
    EXPECT_EQ(Type::None, parser.processByte(0x41).type);
    const auto next = parser.processByte(0);
    EXPECT_EQ(Type::Short, next.type);
    EXPECT_EQ(0x90, next.status);
    EXPECT_EQ(0x41, next.data1);
    EXPECT_EQ(0, next.data2);
}

TEST(MidiStreamParserTest, SingleDataByteAndSystemCommonClearRunningStatus) {
    MidiStreamParser parser;
    parser.processByte(0xC2);
    const auto program = parser.processByte(0x12);
    EXPECT_EQ(Type::Short, program.type);
    EXPECT_EQ(0xC2, program.status);
    EXPECT_EQ(0x12, program.data1);
    EXPECT_EQ(0, program.data2);
    EXPECT_EQ(Type::Short, parser.processByte(0x13).type);
    parser.processByte(0xF1);
    EXPECT_EQ(Type::Short, parser.processByte(0x20).type);
    EXPECT_EQ(Type::None, parser.processByte(0x21).type);
}

TEST(MidiStreamParserTest, SysExIncludesDelimitersAndExcludesRealtime) {
    MidiStreamParser parser;
    parser.processByte(0xF0);
    parser.processByte(0x7E);
    EXPECT_EQ(Type::Short, parser.processByte(0xF8).type);
    parser.processByte(0x01);
    const auto message = parser.processByte(0xF7);
    EXPECT_EQ(Type::SysEx, message.type);
    EXPECT_EQ((std::vector<unsigned char>{0xF0, 0x7E, 0x01, 0xF7}),
            std::vector<unsigned char>(message.sysexData,
                    message.sysexData + message.sysexSize));
}

TEST(MidiStreamParserTest, EmptySysExIsSafe) {
    MidiStreamParser parser;
    parser.processByte(0xF0);
    const auto message = parser.processByte(0xF7);
    ASSERT_EQ(Type::SysEx, message.type);
    ASSERT_EQ(std::size_t{2}, message.sysexSize);
    EXPECT_EQ(0xF0, message.sysexData[0]);
    EXPECT_EQ(0xF7, message.sysexData[1]);
}

TEST(MidiStreamParserTest, MaximumSizeSysExAndOverflowRecovery) {
    MidiStreamParser parser;
    parser.processByte(0xF0);
    for (std::size_t i = 0; i < MidiStreamParser::kMaxSysExSize - 2; ++i) {
        parser.processByte(0x01);
    }
    const auto maximum = parser.processByte(0xF7);
    EXPECT_EQ(Type::SysEx, maximum.type);
    EXPECT_EQ(MidiStreamParser::kMaxSysExSize, maximum.sysexSize);
    parser.processByte(0xF0);
    for (std::size_t i = 0; i < MidiStreamParser::kMaxSysExSize; ++i) {
        EXPECT_EQ(Type::None, parser.processByte(0x01).type);
    }
    EXPECT_EQ(Type::None, parser.processByte(0xF7).type);
    parser.processByte(0xB6);
    parser.processByte(0x0C);
    EXPECT_EQ(Type::Short, parser.processByte(0x7F).type);
}

TEST(MidiStreamParserTest, InterruptedSysExRecoversNewStatus) {
    MidiStreamParser parser;
    parser.processByte(0xF0);
    parser.processByte(0x01);
    parser.processByte(0x90);
    parser.processByte(0x54);
    const auto message = parser.processByte(0x7F);
    EXPECT_EQ(Type::Short, message.type);
    EXPECT_EQ(0x90, message.status);
    EXPECT_EQ(0x54, message.data1);
}

TEST(MidiStreamParserTest, ResetDiscardsPartialMessages) {
    MidiStreamParser parser;
    parser.processByte(0x90);
    parser.processByte(0x40);
    parser.reset();
    EXPECT_EQ(Type::None, parser.processByte(0x7F).type);
    parser.processByte(0xF0);
    parser.processByte(0x01);
    parser.reset();
    EXPECT_EQ(Type::None, parser.processByte(0xF7).type);
}

} // namespace
} // namespace mixxx

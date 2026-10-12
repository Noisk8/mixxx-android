#pragma once

namespace mixxx::audio {

enum class WriteResult { Complete, Cancelled, Error };

template<typename Active, typename Write>
WriteResult writeFrames(int bytes, int frameBytes, Active active, Write write) {
    if (bytes <= 0 || frameBytes <= 0 || bytes % frameBytes != 0) {
        return WriteResult::Error;
    }
    int offset = 0;
    while (offset < bytes) {
        if (!active()) { return WriteResult::Cancelled; }
        const int written = write(offset, bytes - offset);
        if (!active()) { return WriteResult::Cancelled; }
        if (written <= 0 || written > bytes - offset || written % frameBytes != 0) {
            return WriteResult::Error;
        }
        offset += written;
    }
    return WriteResult::Complete;
}

}

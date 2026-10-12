#!/usr/bin/env python3

import argparse
import json
from pathlib import Path
import statistics


def summarize(path):
    samples = [json.loads(line) for line in Path(path).read_text(encoding="utf-8").splitlines() if line.strip()]
    if not samples:
        raise ValueError("Session file contains no samples")
    system = [sample for sample in samples if sample.get("type") == "system"]
    audio = [sample for sample in samples if sample.get("type") == "audio"]
    engine = [sample for sample in samples if sample.get("type") == "engine"]
    duration = (max(sample["elapsedMs"] for sample in samples) - min(sample["elapsedMs"] for sample in samples)) / 1000
    problems = []
    if duration < 7200: problems.append("Playback measurements cover less than two hours")
    if not system: problems.append("System measurements missing")
    if not audio: problems.append("USB channel and underrun measurements missing")
    if not engine: problems.append("Engine timing measurements missing")
    for kind, series in (("system", system), ("audio", audio), ("engine", engine)):
        times = sorted(sample["elapsedMs"] for sample in series)
        if times and (times[-1] - times[0] < max(0, duration * 1000 - 90000)
                      or any(end - start > 90000 for start, end in zip(times, times[1:]))):
            problems.append(f"{kind} measurements have gaps or insufficient coverage")
    if any(sample.get("channels") != 4 or sample.get("indexMask") != 15
           or sample.get("selectedId") != sample.get("routedId") for sample in audio):
        problems.append("Independent four-channel USB route was not confirmed in every sample")
    if audio and any(sample.get("underruns", 0) > audio[0].get("underruns", 0) for sample in audio): problems.append("AudioTrack reported new underruns during the session")
    if engine and any(sample.get("audio_latency_overload_count", 0) > engine[0].get("audio_latency_overload_count", 0) for sample in engine): problems.append("Engine reported new audio overloads during the session")
    if any(sample.get("thermalStatus", 0) >= 3 for sample in system): problems.append("Android reported severe or greater thermal pressure")
    usage = [sample["audio_latency_usage"] for sample in engine if "audio_latency_usage" in sample]
    latency = [sample["output_latency_ms"] for sample in engine if "output_latency_ms" in sample]
    pss = [sample["pssKiB"] for sample in system if "pssKiB" in sample]
    return {
        "duration_seconds": duration,
        "samples": len(samples),
        "pss_initial_mib": pss[0] / 1024 if pss else None,
        "pss_final_mib": pss[-1] / 1024 if pss else None,
        "pss_peak_mib": max(pss) / 1024 if pss else None,
        "render_usage_median": statistics.median(usage) if usage else None,
        "render_usage_peak": max(usage) if usage else None,
        "configured_buffer_latency_peak_ms": max(latency) if latency else None,
        "problems": problems,
        "physical_rca_cue_test": "requires human listening or electrical capture",
        "end_to_end_latency": "requires physical measurement",
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("session", type=Path)
    args = parser.parse_args()
    try:
        print(json.dumps(summarize(args.session), indent=2))
    except (OSError, ValueError, KeyError, TypeError) as error:
        parser.exit(1, f"Session analysis failed: {error}\n")


if __name__ == "__main__":
    main()

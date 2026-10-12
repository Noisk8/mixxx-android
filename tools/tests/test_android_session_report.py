import json
from pathlib import Path
import tempfile
import unittest

from tools.android_session_report import summarize


class SessionReportTest(unittest.TestCase):
    def report(self, samples):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "session.jsonl"
            path.write_text("\n".join(json.dumps(sample) for sample in samples), encoding="utf-8")
            return summarize(path)

    def samples(self):
        series = [
            {"type": "system", "elapsedMs": 0, "thermalStatus": 0, "pssKiB": 102400},
            {"type": "audio", "elapsedMs": 30000, "selectedId": 42, "routedId": 42,
             "channels": 4, "indexMask": 15, "underruns": 0},
            {"type": "engine", "elapsedMs": 7200000, "audio_latency_usage": .3,
             "output_latency_ms": 20, "audio_latency_overload_count": 0},
        ]
        return [{**sample, "elapsedMs": time} for time in range(0, 7200001, 30000) for sample in series]

    def test_complete_measurements(self):
        report = self.report(self.samples())
        self.assertEqual([], report["problems"])
        self.assertEqual(100, report["pss_peak_mib"])
        self.assertEqual(7200, report["duration_seconds"])

    def test_downmix_or_reroute_fails(self):
        for change in [{"channels": 2}, {"indexMask": 3}, {"routedId": 1}]:
            samples = self.samples()
            samples[1].update(change)
            self.assertTrue(self.report(samples)["problems"])

    def test_short_session_with_missing_metrics_fails(self):
        report = self.report([{"type": "system", "elapsedMs": 1}])
        self.assertEqual(3, len(report["problems"]))

    def test_underrun_overload_and_heat_are_reported(self):
        samples = self.samples()
        samples[0]["thermalStatus"] = 3
        samples[-2]["underruns"] = 1
        samples[-1]["audio_latency_overload_count"] = 1
        self.assertEqual(3, len(self.report(samples)["problems"]))

    def test_empty_session_is_rejected(self):
        with self.assertRaises(ValueError): self.report([])

    def test_large_gaps_are_reported(self):
        samples = self.samples()
        samples = [sample for sample in samples if sample["elapsedMs"] not in range(30000, 600000)]
        self.assertEqual(3, len(self.report(samples)["problems"]))

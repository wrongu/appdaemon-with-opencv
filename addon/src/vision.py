import cv2 as cv
import numpy as np
from pathlib import Path
import requests


class CameraMonitor(object):
    def __init__(
        self,
        source_url: str,
        output_dir: Path,
        min_area: int = 500,
        max_background_frames: int = 1000,
        max_interesting_frames: int = 100,
    ):
        self.source = source_url

        self.last_frame = None
        self.current_frame = None

        self.output_dir = output_dir
        self.output_dir.mkdir(parents=True, exist_ok=True)

        self.min_area = min_area

        self._bg_counter = 0
        self._interesting_counter = 0

    def poll(self):
        frame = self.get_frame()
        if frame is not None:
            self.process_frame(frame)
            self.detect_motion()

    def get_frame(self):
        resp = requests.get(self.source, timeout=10)
        if resp.status_code == 200:
            image_array = np.asarray(bytearray(resp.content), dtype=np.uint8)
            frame = cv.imdecode(image_array, cv.IMREAD_COLOR)
            return frame
        else:
            print("Failed to get frame from source:", resp.status_code)
            return None

    def process_frame(self, frame):
        self.last_frame = self.current_frame
        self.current_frame = frame
        cv.imwrite(str(self.output_dir / "latest.jpg"), self.current_frame)
        cv.imwrite(str(self.output_dir / f"background{self._bg_counter:04d}.png"), self.current_frame)
        self._bg_counter += 1

    def detect_motion(self):
        if self.last_frame is None or self.current_frame is None:
            return False

        # Compute the absolute difference between the current frame and the last frame
        diff = cv.absdiff(self.last_frame, self.current_frame)
        gray = cv.cvtColor(diff, cv.COLOR_BGR2GRAY)
        blur = cv.GaussianBlur(gray, (5, 5), 0)
        _, thresh = cv.threshold(blur, 20, 255, cv.THRESH_BINARY)

        # Clean up the thresholded image with morphological operations.
        kernel = np.ones((5, 5), np.uint8)
        # First, remove specks using opening.
        opened = cv.morphologyEx(thresh, cv.MORPH_OPEN, kernel)
        # Then, close gaps using closing.
        closed = cv.morphologyEx(opened, cv.MORPH_CLOSE, kernel)

        # Look for large objects in the closed image.
        num_labels, labels, stats, centroids = cv.connectedComponentsWithStats(
            closed, connectivity=8
        )
        for i in range(1, num_labels):
            # If the area of the object is large enough, consider it motion and save the frame.
            if stats[i, cv.CC_STAT_AREA] > self.min_area:
                cv.imwrite(str(self.output_dir / f"interesting{self._interesting_counter:04d}.png"), self.current_frame)
                self._interesting_counter += 1

    def reset(self):
        self.last_frame = None
        self.current_frame = None
        self._bg_counter = 0
        self._interesting_counter = 0

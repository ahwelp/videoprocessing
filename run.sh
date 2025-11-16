#!/bin/bash
docker run --rm \
  -v "$PWD/source_videos:/workspace/source_videos" \
  -v "$PWD/restored_videos:/workspace/restored_videos" \
  -v "$PWD/plugins:/workspace/plugins" \
  -v "$PWD/script:/workspace/script" \
  --device=/dev/dri \
  --device-cgroup-rule='c 226:* rmw' \
  --group-add video \
  --group-add render \
  vapoursynth /workspace/scripts/preset_vhs_gpu.vpy

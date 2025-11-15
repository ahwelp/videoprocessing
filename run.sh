#!/bin/bash
docker run --rm \
  -v "$PWD/source_videos:/workspace/source_videos" \
  -v "$PWD/restored_videos:/workspace/restored_videos" \
  -v "$PWD/plugins:/workspace/plugins" \
  -v "$PWD/script:/workspace/script" \
  --device /dev/dri \
  vapoursynth /workspace/scripts/preset_vhs_gpu.vpy

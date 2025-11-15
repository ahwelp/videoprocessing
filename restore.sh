#!/bin/bash

SCRIPT="$1"

export PLUGIN_LOCATION="/workspace/plugins"

for FILE in source_videos/*; do
  export SOURCE_VIDEO="/workspace/source_videos/$FILE"
  
  echo "Step 1: Deinterlace + Denoise (VapourSynth QTGMC)"
  vspipe "$SCRIPT" - -c y4m | ffmpeg -y -i - -c:v libx264 -pix_fmt yuv420p -preset medium -crf 18 "/workspace/restored_videos/${FILE}_qtgmc.mp4"

  echo "Step 2: Deartifact + Upscale (Real-ESRGAN)"
  real-esrgan-ncnn-vulkan -i "/workspace/restored_videos/${FILE}_qtgmc.mp4" \
  real-esrgan-ncnn-vulkan -i "$SOURCE_VIDEO" \
      -o "/workspace/restored_videos/${FILE}_upscaled.mp4" -n realesr-animevideov3

  echo "Step 3: Color Balance (FFmpeg)"
  ffmpeg -y -i "/workspace/restored_videos/${FILE}_upscaled.mp4" \
      -vf "eq=contrast=1.15:brightness=0.03:saturation=1.25,curves=strong_contrast" \
      -c:v libx264 -preset slow -crf 18 "/workspace/restored_videos/${NAME}_color.mp4"
      
  echo "Step 4: Frame Interpolation (RIFE)"
  rife-ncnn-vulkan -i "/workspace/restored_videos/${FILE}_color.mp4" \
      -o "/workspace/restored_videos/${FILE}_final.mp4" -n rife-v4.6
      
  echo "Process completed: /workspace/restored_videos/${FILE}_final.mp4"
done

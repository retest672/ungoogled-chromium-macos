#!/bin/bash -eux

# Simple partitioned (2 of 3) build script for building Ungoogled-Chromium macOS binaries on GitHub Actions
# Resuming build script for macOS

_root_dir=$(dirname $(greadlink -f $0))
if [[ -f "$_root_dir/epoch_job_start.txt" ]]; then
  epoch_job_start=$(cat "$_root_dir/epoch_job_start.txt")
  # GitHub's hard time limit is 6 h per job, we want to spare 37 min for steps after the build, 
  # To get the remaining time for building we subtract 360*60s - 37*60s - (epoch_now - epoch_job_start)
  _remaining_time=$(( 360*60 - 37*60 - $(date +%s) + epoch_job_start ))
fi

cd build/src

echo $(date +%s) | tee -a "$_root_dir/build_times.log"
# echo "::set-output name=status::running"
echo "status=running" >> $GITHUB_OUTPUT

timeout -k 7m -s SIGTERM ${_remaining_time:-19200}s ninja -C out/Default chrome chromedriver # 320 m as default $_remaining_time

echo $(date +%s) | tee "$_root_dir/build_finished.log"
# echo "::set-output name=status::finished"
echo "status=finished" >> $GITHUB_OUTPUT

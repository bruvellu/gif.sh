#!/bin/sh

# Converts video to high-quality animated GIF using FFmpeg

# Script parameters
usage() {
  echo "Usage:";
  echo "\t./gif.sh [<options>] -i input.avi -o output.gif";
  echo "Required:"
  echo "\t-i input movie\t.avi, .mp4, etc";
  echo "\t-o output gif\t.gif";
  echo "Optional:"
  echo "\t-s start time\t<mm:ss>, defaults to 00:00";
  echo "\t-d duration\t<seconds>, defaults to input duration";
  echo "\t-f fps\t\t<frames-per-second>, defaults to input fps";
  echo "\t-x scale\t<width-in-pixels>, defaults to input width";
  exit 1;
}

# Default options

# Temporary palette file
PALETTE="/tmp/palette.png"

# Set start time
START=00:00

# Parse arguments
while getopts "i:o:s:d:f:x:" option; do
  case "${option}" in
    i) INPUT="${OPTARG}" ;;
    o) OUTPUT="${OPTARG}" ;;
    s) START="${OPTARG}" ;;
    d) DURATION="${OPTARG}" ;;
    f) FPS="${OPTARG}" ;;
    x) SCALE="${OPTARG}" ;;
    ?) usage ;;
  esac
done

# TODO: Implement speed up or slow down using SETPTS="0.4*PTS"
# TODO: Define cropping area using CROP="440:440:135:15"

# Abort if required arguments are missing
if [ -z "${INPUT}" ] || [ -z "${OUTPUT}" ]; then
    usage
fi

# Fetch duration from video, if not provided
if [ -z "${DURATION}" ]; then
  DURATION=`ffmpeg -i ${INPUT} 2>&1 | grep -oE 'Duration: [[:digit:]]{2}:[[:digit:]]{2}:[[:digit:]]{2}.[[:digit:]]{2}' | cut -d : -f 4`
fi

# Fetch fps from video, if not provided
if [ -z "${FPS}" ]; then
  FPS=`ffmpeg -i ${INPUT} 2>&1 | grep -oE '[[:digit:]]{1,4} fps' | cut -d ' ' -f 1`
fi

# Fetch width from video, if not provided
if [ -z "${SCALE}" ]; then
  SCALE=`ffmpeg -i ${INPUT} 2>&1 | grep -oE ', [[:digit:]]{1,4}x[[:digit:]]{1,4}' | cut -d ' ' -f 2 | cut -d 'x' -f 1`
fi

# Print parameters
echo "\nParameters:"
echo "input = ${INPUT}"
echo "output = ${OUTPUT}"
echo "start = ${START}"
echo "duration = ${DURATION}s"
echo "fps = ${FPS}"
echo "width = ${SCALE}px"

# Apply filters
FILTERS="fps=${FPS},scale=${SCALE}:-1:flags=lanczos"

# Run two pass conversion
echo "\nProcessing..."
ffmpeg -v warning -ss ${START} -t ${DURATION} -i ${INPUT} -vf "$FILTERS,palettegen" -y ${PALETTE}
ffmpeg -v warning -ss ${START} -t ${DURATION} -i ${INPUT} -i ${PALETTE} -lavfi "$FILTERS [x]; [x][1:v] paletteuse" -y ${OUTPUT}
echo "Done!"


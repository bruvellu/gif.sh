#!/bin/sh

# Converts any video to animated gif

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
  exit 1;
}

# Default options

# Temporary palette file
PALETTE="/tmp/palette.png"
# Set start time
START=00:00

## Speed up or slow down
#SETPTS="0.4*PTS"
## Set crop area
#CROP="440:440:135:15"
## Scale if needed
#SCALE="440:-1:flags=lanczos"

# Parse arguments
while getopts "i:o:s:d:f:" option; do
  case "${option}" in
    i) INPUT="${OPTARG}" ;;
    o) OUTPUT="${OPTARG}" ;;
    s) START="${OPTARG}" ;;
    d) DURATION="${OPTARG}" ;;
    f) FPS="${OPTARG}" ;;
    ?) usage ;;
  esac
done

# Abort without required arguments
if [ -z "${INPUT}" ] || [ -z "${OUTPUT}" ]; then
    usage
fi

# Fetch duration from video if not provided
if [ -z "${DURATION}" ]; then
  DURATION=`ffmpeg -i ${INPUT} 2>&1 | grep -oE 'Duration: [[:digit:]]{2}:[[:digit:]]{2}:[[:digit:]]{2}.[[:digit:]]{2}' | cut -d : -f 4`
fi

# Fetch fps from video if not provided
if [ -z "${FPS}" ]; then
  FPS=`ffmpeg -i ${INPUT} 2>&1 | grep -oE '[[:digit:]]{1,4} fps' | cut -d ' ' -f 1`
fi

# Print parameters
echo "\nParameters:"
echo "input = ${INPUT}"
echo "output = ${OUTPUT}"
echo "start = ${START}"
echo "duration = ${DURATION}s"
echo "fps = ${FPS}"

# Apply filters
#filters="fps=15,setpts=0.4*PTS,crop=440:440:135:15,scale=440:-1:flags=lanczos"
FILTERS="fps=${FPS}"

# Run two pass conversion
echo "\nProcessing..."
ffmpeg -v warning -ss ${START} -t ${DURATION} -i ${INPUT} -vf "$FILTERS,palettegen" -y ${PALETTE}
ffmpeg -v warning -ss ${START} -t ${DURATION} -i ${INPUT} -i ${PALETTE} -lavfi "$FILTERS [x]; [x][1:v] paletteuse" -y ${OUTPUT}
echo "Done!"

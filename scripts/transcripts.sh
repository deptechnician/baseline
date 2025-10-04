#!/bin/bash
set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <YouTube channel URL>"
  exit 1
fi

CHANNEL_URL="$1"

# Extract channel name from @handle, /c/, or /channel/ URLs
# e.g. "https://www.youtube.com/@AmeliaAndJP" → "AmeliaAndJP"
CHANNEL_NAME=$(basename "$CHANNEL_URL" | sed 's/^@//')

# Use it as the transcript directory name
TRANSCRIPT_DIR="${CHANNEL_NAME}"
mkdir -p "$TRANSCRIPT_DIR"

echo "📁 Saving transcripts to: $TRANSCRIPT_DIR"
echo "🔍 Getting video URLs from: $CHANNEL_URL"

# Get all video URLs from the channel (handles, playlists, etc.)
mapfile -t video_urls < <(yt-dlp "$CHANNEL_URL" --flat-playlist --get-id | sed 's_^_https://www.youtube.com/watch?v=_')

for video_url in "${video_urls[@]}"; do
  echo "🎬 Processing: $video_url"

  # Safe filename
  title=$(yt-dlp --get-title "$video_url" | sed 's/[\/:*?"<>|]/_/g')
  srt_path="$TRANSCRIPT_DIR/$title.en.srt"
  txt_path="$TRANSCRIPT_DIR/$title.en.txt"

  if [ -f "$txt_path" ]; then
    echo "✅ Already processed: $title"
    continue
  fi

  echo "⬇️ Downloading subtitles..."
  yt-dlp --skip-download \
         --write-auto-subs \
         --sub-format "srt" \
         --sub-lang "en" \
         -o "$TRANSCRIPT_DIR/$title.%(ext)s" \
         "$video_url"

  if [ -f "$srt_path" ]; then
    echo "🧼 Cleaning transcript..."
    python3 "$HOME"/Code/baseline/scripts/srt_to_clean_text.py "$srt_path" "$txt_path"
  else
    echo "⚠️ No subtitles found for: $title"
  fi
done

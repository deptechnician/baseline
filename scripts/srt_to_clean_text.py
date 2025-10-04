import sys
import re

def insert_newlines(text, max_len=100):
    pos = 0
    length = len(text)
    result = ""

    while pos < length:
        # If remaining text is shorter than max_len, just add rest and break
        if length - pos <= max_len:
            result += text[pos:]
            break

        # Find first space after max_len characters from pos
        space_index = text.find(' ', pos + max_len)

        if space_index == -1:
            # No more spaces, append rest and break
            result += text[pos:]
            break

        # Append up to space_index, plus newline
        result += text[pos:space_index] + '\n'
        pos = space_index + 1  # Move past the space

    return result

def srt_to_clean_text(srt_path, output_path):
    with open(srt_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    text_lines = []
    last_line = ""

    for line in lines:
        line = line.strip()
        if not line or line.isdigit() or '-->' in line:
            continue
        if line == last_line:
            continue
        text_lines.append(line)
        last_line = line

    text = ' '.join(text_lines)
    text = re.sub(r'\s+', ' ', text)

    # Insert newline after first space beyond 100 chars repeatedly
    text = insert_newlines(text, 100)

    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(text.strip() + '\n')

    print(f"✅ Cleaned transcript saved to: {output_path}")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python srt_to_clean_text.py input.srt output.txt")
        sys.exit(1)

    srt_to_clean_text(sys.argv[1], sys.argv[2])

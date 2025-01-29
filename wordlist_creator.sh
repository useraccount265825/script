#!/bin/bash

# Prompt for the base word
read -p "Enter the base word for your password list (e.g., ): " BASE_WORD
OUTPUT_FILE="passwords.txt"

# Clear the output file if it exists
> "$OUTPUT_FILE"

# Prompt for numeric range
read -p "Enter a numeric range (1-10): " NUMERIC_RANGE

# Validate the numeric range input
if ! [[ "$NUMERIC_RANGE" =~ ^[1-9]$|^10$ ]]; then
    echo "Invalid input. Please enter a number between 1 and 10."
    exit 1
fi

# Common password words
COMMON_PASSWORDS=(
    "password" "123456" "qwerty" "letmein" "welcome" "admin" "user" "guest"
    "p@ssw0rd" "1q2w3e4r" "abc123" "password1" "iloveyou" "sunshine" "football"
)

# Generate variations
# 1. word + numeric
for ((i=1; i<=NUMERIC_RANGE; i++)); do
    echo "${BASE_WORD}${i}" >> "$OUTPUT_FILE"
done

# 2. word + special char
for char in "!" "@" "#" "$" "%" "^" "&" "*"; do
    echo "${BASE_WORD}${char}" >> "$OUTPUT_FILE"
done

# 3. word + year (e.g., 2020-2024)
for year in {2020..2024}; do
    echo "${BASE_WORD}${year}" >> "$OUTPUT_FILE"
done

# 4. word + numeric + special char
for ((i=1; i<=NUMERIC_RANGE; i++)); do
    for char in "!" "@" "#" "$" "%" "^" "&" "*"; do
        echo "${BASE_WORD}${i}${char}" >> "$OUTPUT_FILE"
    done
done

# 5. word + numeric + year
for ((i=1; i<=NUMERIC_RANGE; i++)); do
    for year in {2020..2024}; do
        echo "${BASE_WORD}${i}${year}" >> "$OUTPUT_FILE"
    done
done

# 6. word + special char + numeric
for ((i=1; i<=NUMERIC_RANGE; i++)); do
    for char in "!" "@" "#" "$" "%" "^" "&" "*"; do
        echo "${BASE_WORD}${char}${i}" >> "$OUTPUT_FILE"
    done
done

# 7. word + _ + numeric
for ((i=1; i<=NUMERIC_RANGE; i++)); do
    echo "${BASE_WORD}_${i}" >> "$OUTPUT_FILE"
done

# 8. word + @ + special char
for char in "!" "#" "$" "%" "^" "&" "*"; do
    echo "${BASE_WORD}@${char}" >> "$OUTPUT_FILE"
done

# 9. All possible combinations with common words
for COMMON in "${COMMON_PASSWORDS[@]}"; do
    echo "${COMMON}${BASE_WORD}" >> "$OUTPUT_FILE"
    echo "${BASE_WORD}${COMMON}" >> "$OUTPUT_FILE"
done

# Notify user of completion
echo "Password list generated: $OUTPUT_FILE"

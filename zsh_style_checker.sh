#!/bin/zsh
# Comprehensive capitalization style checker
# Incorporates Google Style Guide and Writer.com capitalization rules

print "\033[1;36mComprehensive Capitalization Style Checker\033[0m"
print "Based on: https://developers.google.com/style/capitalization"
print "and: https://writer.com/blog/capitalization-rules/"
print ""

# Always lowercase in titles (unless first or last word)
ALWAYS_LOWERCASE=(
  "a" "an" "the" 
  "and" "but" "or" "nor" "for" 
  "to" "at" "by" "with" "about" "as" 
  "in" "of" "on" "per" "via" "vs." "vs" "versus"
)

# Always capitalize these tech terms
TECH_TERMS=(
  "API:api"
  "APIs:apis"
  "CLI:cli"
  "CPU:cpu"
  "CSS:css"
  "DNS:dns"
  "HTML:html"
  "HTTP:http"
  "HTTPS:https"
  "ID:id"
  "IP:ip"
  "JSON:json"
  "SDK:sdk"
  "SQL:sql"
  "URL:url"
  "XML:xml"
  "YAML:yaml"
  "UI:ui"
  "UX:ux"
  "JavaScript:javascript"
  "Python:python"
  "Java:java"
  "Go:golang"
  "GitHub:github"
  "Git:git"
)

# Other capitalization rules
PROPER_NOUNS=(
  "Monday" "Tuesday" "Wednesday" "Thursday" "Friday" "Saturday" "Sunday"
  "January" "February" "March" "April" "May" "June" "July" "August" "September" "October" "November" "December"
  "English" "Spanish" "French" "German" "Italian" "Chinese" "Japanese" "Korean"
)

# Function to check headings for title case rules
check_heading_capitalization() {
  local file=$1
  print "\033[1;33mChecking heading capitalization in $file...\033[0m"
  
  # Extract markdown headings using grep
  grep -n "^#\+ .*" "$file" | while read -r line; do
    line_num=$(echo $line | cut -d':' -f1)
    heading=$(echo $line | cut -d':' -f2- | sed 's/^#\+ //')
    
    # Check if first word is lowercase
    first_word=$(echo $heading | awk '{print $1}' | tr -d ',:;')
    if [[ $(echo $first_word | grep -c "^[a-z]") -gt 0 ]]; then
      print "  Line $line_num: First word in heading should be capitalized: '$first_word'"
    fi
    
    # Check if last word is lowercase
    last_word=$(echo $heading | awk '{print $NF}' | tr -d ',:;')
    if [[ $(echo $last_word | grep -c "^[a-z]") -gt 0 ]]; then
      print "  Line $line_num: Last word in heading should be capitalized: '$last_word'"
    fi
    
    # Check for words that should be lowercase in titles
    words=(${(s: :)heading})
    for ((i=2; i<${#words}; i++)); do
      # Check if it's not the last word
      if [[ $i -lt $(( ${#words} - 1 )) ]]; then
        word=$(echo ${words[$i]} | tr -d ',:;')
        lowercase_word=$(echo $word | tr '[:upper:]' '[:lower:]')
        
        # Check if this word should be lowercase
        for lc in $ALWAYS_LOWERCASE; do
          if [[ $lowercase_word == $lc ]]; then
            if [[ $(echo $word | grep -c "^[A-Z]") -gt 0 ]]; then
              print "  Line $line_num: Word '$word' should be lowercase in heading"
            fi
          fi
        done
      fi
    done
  done
}

# Function to check for proper technical term capitalization
check_tech_terms() {
  local file=$1
  print "\033[1;33mChecking technical term capitalization in $file...\033[0m"
  
  for term_pair in $TECH_TERMS; do
    correct=$(echo $term_pair | cut -d':' -f1)
    incorrect=$(echo $term_pair | cut -d':' -f2)
    
    # Skip searching for single-letter terms like "i" which would cause false positives
    if [[ ${#incorrect} -gt 1 ]]; then
      grep -n "\b$incorrect\b" "$file" | while read -r line; do
        line_num=$(echo $line | cut -d':' -f1)
        content=$(echo $line | cut -d':' -f2-)
        print "  Line $line_num: '$incorrect' should be '$correct'"
      done
    fi
  done
}

# Function to check sentence case
check_sentence_case() {
  local file=$1
  print "\033[1;33mChecking sentence case in $file...\033[0m"
  
  # Look for sentences that start with lowercase letters
  # This is a simplified approach - real sentence detection is more complex
  grep -n -E "(^|[.!?]\s+)[a-z]" "$file" | while read -r line; do
    line_num=$(echo $line | cut -d':' -f1)
    content=$(echo $line | cut -d':' -f2-)
    print "  Line $line_num: Sentence should start with capital letter: '$(echo $content | grep -o -E "(^|[.!?]\s+)[a-z][^.!?]*" | head -1)'"
  done
}

# Function to check proper noun capitalization
check_proper_nouns() {
  local file=$1
  print "\033[1;33mChecking proper noun capitalization in $file...\033[0m"
  
  for noun in $PROPER_NOUNS; do
    lowercase=$(echo $noun | tr '[:upper:]' '[:lower:]')
    grep -n "\b$lowercase\b" "$file" | while read -r line; do
      line_num=$(echo $line | cut -d':' -f1)
      print "  Line $line_num: Proper noun '$lowercase' should be capitalized as '$noun'"
    done
  done
}

# Function to check for ampersand usage
check_ampersand() {
  local file=$1
  print "\033[1;33mChecking for ampersand usage in $file...\033[0m"
  
  grep -n "&" "$file" | while read -r line; do
    line_num=$(echo $line | cut -d':' -f1)
    content=$(echo $line | cut -d':' -f2-)
    print "  Line $line_num: Ampersand '&' should be replaced with 'and'"
  done
}

# Function to check specific Writer.com rules
check_writer_rules() {
  local file=$1
  print "\033[1;33mChecking Writer.com capitalization rules in $file...\033[0m"
  
  # Check job titles when they precede a name
  grep -n -E "(^|\s)[a-z]+\s+[A-Z][a-z]+" "$file" | while read -r line; do
    line_num=$(echo $line | cut -d':' -f1)
    content=$(echo $line | cut -d':' -f2-)
    
    # Check common job titles that should be capitalized when they precede a name
    for title in "president" "ceo" "director" "manager" "professor" "doctor" "chief"; do
      if echo "$content" | grep -q -E "(^|\s)$title\s+[A-Z][a-z]+"; then
        print "  Line $line_num: Job title should be capitalized when preceding a name: found '$(echo $content | grep -o -E "(^|\s)$title\s+[A-Z][a-z]+" | sed 's/^\s*//')'"
      fi
    done
  done
  
  # Check for uncapitalized first words after colons in titles
  grep -n -E "^#+.*:.*" "$file" | while read -r line; do
    line_num=$(echo $line | cut -d':' -f1)
    content=$(echo $line | cut -d':' -f2-)
    
    if echo "$content" | grep -q -E ":\s*[a-z]"; then
      print "  Line $line_num: Word after colon in heading should be capitalized"
    fi
  done
  
  # Check for incorrectly capitalized directions (north, south, etc.) when not part of a proper name
  for direction in "north" "south" "east" "west" "northeast" "northwest" "southeast" "southwest"; do
    uppercase=$(echo $direction | sed 's/^./\U&/')
    grep -n "\b$uppercase\b" "$file" | grep -v -E "(North|South|East|West|Northeast|Northwest|Southeast|Southwest) (America|Carolina|Dakota|Korea)" | while read -r line; do
      line_num=$(echo $line | cut -d':' -f1)
      print "  Line $line_num: Direction '$uppercase' should be lowercase when not part of a proper name"
    done
  done
}

# Main function to process the directory
process_directory() {
  local directory=$1
  
  # Find all documentation files
  find "$directory" -type f \( -name "*.md" -o -name "*.txt" -o -name "*.html" -o -name "*.rst" \) | while read -r file; do
    print "\n\033[1;32mAnalyzing: $file\033[0m"
    
    check_heading_capitalization "$file"
    check_tech_terms "$file"
    check_sentence_case "$file"
    check_proper_nouns "$file"
    check_ampersand "$file"
    check_writer_rules "$file"
    
    print ""
  done
}

# Main execution
if [[ "$1" == "--dir" ]]; then
  if [[ -z "$2" ]]; then
    print "Please specify a directory"
    exit 1
  fi
  
  process_directory "$2"
else
  print "Usage: ./style_checker.sh --dir <directory>"
  exit 1
fi
#!/bin/bash
source bash_loading_animations.sh
# Stop loading animation if the script is interrupted
# trap BLA::stop_loading_animation SIGINT
traps() {
  printout;
  BLA::stop_loading_animation;
}
trap traps SIGINT

#
# Get images from 4chan imageboard
# Download images from 4chan library
#
#-------------------------------------------------------------------------------
#
# ISTRUCTIONS
# Go to https://4chan.org/
# Copy the URLs of the Boards your are interested and paste them line-by-line in
# the `4chan_sources.txt` file

input="4chan_sources.txt"
target_folder="dataset/training_samples/"
# now=$(date +"%Y-%m-%d")
log_file="logs/saved_images-$(date +"%Y-%m-%d").log"
max_pages=5

###


printout() {
    echo ""
    echo ""
    echo -e "\e[38;5;215mStopped downloading images at the $i list item, url $new_url\e[0m"
    exit
}

loading_animation() {
  BLA_active_loading_animation=( "${@}" )
  # Extract the delay between each frame from the active_loading_animation array
  BLA_loading_animation_frame_interval="${BLA_active_loading_animation[0]}"
  # Sleep long enough that all frames are showed
  # substract 1 to the number of frames to account for index [0]
  demo_duration=$( echo "${BLA_active_loading_animation[0]} * ( ${#BLA_active_loading_animation[@]} - 1 )" | bc )
  # Make sure each animation is shown for at least 3 seconds
  if [[ $( echo "if (${demo_duration} < 3) 0 else 1" | bc ) -eq 0 ]] ; then
    demo_duration=3
  fi
  unset "BLA_active_loading_animation[0]"
  echo
  BLA::play_loading_animation_loop &
  BLA_loading_animation_pid="${!}"
  sleep "${demo_duration}"
  # kill "${BLA_loading_animation_pid}" &> /dev/null
  # clear
}

tput civis # Hide the terminal cursor
echo -e "\e[38;5;245mGetting images from source list $input...\e[0m"
while IFS= read -r images_url
do
  page=1

  for i in $( eval echo {1..$max_pages} )
  do
    new_url=$images_url

    if [[ $page > 1 ]]; then
      new_url+=$page
    fi

    loading_animation "${BLA_metro[@]}"

    # see https://gist.github.com/tayfie/6dad43f1a452440fba7ea1c06d1b603a
    wget --report-speed=bits -P pictures -nd -r -l 2 -H -D i.4cdn.org -A png,gif,jpg,jpeg,webm,mov,mp4 -P $target_folder $new_url -a $log_file
    echo -ne " \e[38;5;70m✔\e[0m"
    kill "${BLA_loading_animation_pid}" &> /dev/null
    ((page++));
  done
  # clear
  # sleep 5
done < "$input"

# downlodaded_imgs=$(grep "Salvataggio in: " logs/2024-12-24\ saved_images.log | wc -l -1)
downlodaded_imgs=$(ls -1 $target_folder | wc -l)
echo
if [[ downlodaded_imgs == 1 ]]; then
  imgs="image"
else
  imgs="images"
fi

echo -e "\e[38;5;245mDownloaded $downlodaded_imgs $imgs from $input...\e[0m"
tput cnorm # Restore the terminal cursor
exit 0

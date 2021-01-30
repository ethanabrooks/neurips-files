#! /usr/bin/env bash

nruns=5

while getopts c:n: flag
do
    case "${flag}" in
      c) config=${OPTARG};;
      n) name=${OPTARG};;
      *) echo "usage: run.sh -c <config> -n <name> -r <nruns> -s <session>" && exit;;
    esac
done

session="$name-"
wandb_output=$(wandb sweep --name "$name" "$config" 2> >(tee >(cat 1>&2)))
dir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd)
id=$(echo $wandb_output | tail -n1 | awk 'END {print $NF}')

echo "Creating $nruns sessions..."

for i in $(seq 0 $(( $nruns-1))); do
  echo "tmux at -t $session$i"
  tmux new-session -d -s "$session$i" "wandb agent $id"
  #echo docker run \
    #--rm \
    #--detach \
    #--gpus $gpu \
    #--volume $(pwd):/ppo \
    #--env WANDB_API_KEY=$key \
    #ethanabrooks/ppo $id
done

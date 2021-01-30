import argparse
from pathlib import Path
import wandb

from tensorboard.backend.event_processing.event_file_loader import EventFileLoader


def main(events: Path, use_wandb: bool):
    if use_wandb:
        wandb.init(project="control-flow")

    events_file = next(events.iterdir())
    for data in EventFileLoader(str(events_file)).Load():
        try:
            assert len(data.summary.value) <= 1
            tag = data.summary.value[0].tag
            (value,) = data.summary.value[0].tensor.float_val
            if use_wandb:
                wandb.log({tag: value}, step=data.step)
            else:
                print(data.step, tag, data.summary.value[0].tensor.float_val[0])
        except (AttributeError, IndexError):
            continue


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--events", type=Path)
    parser.add_argument("--no_wandb", dest="use_wandb", action="store_false")
    main(**vars(parser.parse_args()))

import logging
import os
import shutil

import click

NOTES_PER_OCTAVE = 12

logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)


def get_note(filename):
    """Gets note from filename assuming format is `Synth_Instrument_B1.wav`"""
    base_filename, _ = os.path.splitext(filename)
    return base_filename.split('_')[-1]


def rank_note(note):
    octave = int(note[-1])
    pitch_class = note[:-1]
    return {
        'c': 0,
        'c#': 1,
        'd': 2,
        'd#': 3, 
        'e': 4,
        'f': 5,
        'f#': 6,
        'g': 7,
        'g#': 8,
        'a': 9,
        'a#': 10,
        'b': 11,
    }[pitch_class.lower()] + (octave * NOTES_PER_OCTAVE)


def is_wav(filename):
    _, extension = os.path.splitext(filename)
    return extension.lower() == '.wav'


@click.command()
@click.argument('source')
@click.argument('destination')
def number_samples(source, destination):
    os.makedirs(destination, exist_ok=True)

    _, _, existing_filenames = next(os.walk(source))
    for filename in filter(is_wav, existing_filenames):
        new_filename = f'{rank_note(get_note(filename)):03}_{filename}'
        source_path = os.path.join(source, filename)
        destination_path = os.path.join(destination, new_filename)
    
        logger.info(f'Copying {source_path} to {destination_path}')
        shutil.copy(source_path, destination_path)


if __name__ == '__main__':
    number_samples()


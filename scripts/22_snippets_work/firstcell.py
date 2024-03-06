## magic
%reload_ext autoreload
%autoreload 2
%matplotlib inline
%precision 5
# %load_ext memory_profiler

## essentials
import os, sys, shutil, re
from pathlib import Path
from typing import *

## plotting
import matplotlib as mpl
import matplotlib.pyplot as plt
import seaborn as sns
mpl.rcParams['figure.dpi'] = 150
sns.set_theme(style="whitegrid")

## scientific stack
import numpy as np
import pandas as pd
from tqdm.auto import tqdm
pd.set_option('display.max_rows', 100)
pd.set_option('display.max_columns', 30)
pd.set_option('display.max_colwidth', 200)
pd.set_option('display.precision', 5)

## global variables
AITIOS_PALETTE = {
    "blue": "#1D6AC4",
    "orange": "#EE8155",
    "turqoise": "#21BEC1",
    "purple": "#854DBD",
    "yellow": "#F4BF29",
    "black": "#000000",
    "green": "#BCBD22",
    "red": "#D32F2F",
    "grey": "#7F7F7F"
}

## utility functions
def ls(s: Path):
    s = Path(str(s))
    print('\n'.join(list(str(x) for x in s.iterdir())))
Path.ls = ls

def notify_tg(msg: str) -> bool:
    import requests
    token = os.environ['LLF_TG_BOT_TOKEN']
    chat_id = os.environ['LLF_TG_CHAT_ID']
    post_url = f'https://api.telegram.org/bot{token}/sendMessage'
    data = {'chat_id': int(chat_id), 'text': msg}
    retval = requests.post(post_url, data).json()
    return retval.get('ok', False)

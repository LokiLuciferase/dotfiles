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
sns.set(style="whitegrid")

## scientific stack
import numpy as np
import pandas as pd
from tqdm.auto import tqdm
pd.set_option('display.max_rows', 100)
pd.set_option('display.max_columns', 30)
pd.set_option('display.max_colwidth', 200)
pd.set_option('display.precision', 5)

ARES_PALETTE = [
    '#79b8e8',  # light blue
    '#1464a0',  # dark blue
    '#87b919',  # green
    '#ff9600',  # orange
    '#de3b36',  # red
    '#000000',  # black
    '#d8d8d8',  # light grey
    '#474747',  # dark grey
]
LLF_TG_CHAT_ID = os.getenv('LLF_TG_CHAT_ID')
LLF_TG_BOT_TOKEN = os.getenv('LLF_TG_BOT_TOKEN')

def ls(s: Path):
    s = Path(str(s))
    print('\n'.join(list(str(x) for x in s.iterdir())))
Path.ls = ls

def notify_tg(msg: str) -> bool:
    import requests

    post_url = f'https://api.telegram.org/bot{LLF_TG_BOT_TOKEN}/sendMessage'
    data = {'chat_id': int(LLF_TG_CHAT_ID), 'text': msg}
    retval = requests.post(post_url, data).json()
    return retval.get('ok', False)

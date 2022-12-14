# -*- coding: utf-8 -*-
"""Checkpoint3.ipynb

Automatically generated by Colaboratory.

Original file is located at
    https://colab.research.google.com/drive/19vbP4gJBUZSh7VpjllxTgygoXs-xEMRU
"""

import pandas as pd
import operator as op

path = '/content/district_data.csv'

 data = pd.read_csv(path)

df = pd.DataFrame(data)

df

def func1(x):
  ppl = {
          'Black': x['black'],
          'White': x['white'],
          'Hispanic': x['hispanic'],
          'Other':  x['other'],
      }
  max_value = max(ppl, key=ppl.get)
  x['main_population'] = max_value
  return x

df = df.apply(func1, axis=1)

df['police_nonwhite'] = 1 - df['police_white']
df['police_male'] = 1 - df['police_female']

df

df = pd.DataFrame(df, columns=['district', 'main_population', 'district_misconduct_rate','police_male', 'police_nonwhite'])
filtered_df = df[df['district_misconduct_rate'].notnull()]

filtered_df

filtered_df.to_csv('district_filtered_data.csv', header=True)
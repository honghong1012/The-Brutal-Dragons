import pandas as pd


def read_all_data():
    path = 'test.csv'
    a_data = pd.read_csv(path)
    return a_data


def category_helper(data, m_data):
    data.insert(data.shape[1], 'white', 0)
    data.insert(data.shape[1], 'black', 0)
    data.insert(data.shape[1], 'other', 0)
    data.insert(data.shape[1], 'black_dominant_district', 0)
    data.insert(data.shape[1], 'non_black_dominant_district', 0)
    data.insert(data.shape[1], 'female', 0)
    data.insert(data.shape[1], 'male', 0)
    data.insert(data.shape[1], 'misconduct_rate_higher_than_11', 0)
    data.insert(data.shape[1], 'misconduct_rate_level', 'low')
    black_district = [8, 11, 9, 14]
    # gender
    data.loc[data.gender == 'M', 'male'] = 1
    data.loc[data.gender == 'F', 'female'] = 1
    # race
    data.loc[data.race == 'Black', 'black'] = 1
    data.loc[data.race == 'White', 'white'] = 1
    data.loc[(data.black != 1) & (data.white != 1), 'other'] = 1
    # district
    data.loc[(data.unit_name == 8) | (data.unit_name == 11) | (data.unit_name == 9) | (data.unit_name == 14),
             'black_dominant_district'] = 1
    data.loc[data.black_dominant_district == 0, 'non_black_dominant_district'] = 1

    for key, value in m_data.items():
        if 0.11 <= value < 0.25:
            data.loc[data.unit_name == key, 'misconduct_rate_level'] = 'medium'
        if 0.25 <= value:
            data.loc[data.unit_name == key, 'misconduct_rate_level'] = 'high'

    copy = data.drop(['gender', 'race'], axis=1)
    return copy


def process_misconduct():
    misconduct_rate = pd.read_csv('csv/The_misconduct_rate.csv')
    d = dict()
    for index, row in misconduct_rate.iterrows():
        d_n = int(row['district'])
        if not pd.isna(row['district_misconduct_rate']):
            d[d_n] = float(row['district_misconduct_rate'])
    return d


if __name__ == "__main__":
    dataset = []
    misconduct_data = process_misconduct()
    csv = read_all_data()
    res = category_helper(csv, misconduct_data)
    res.to_csv('cp4_data_4.csv', header=True)


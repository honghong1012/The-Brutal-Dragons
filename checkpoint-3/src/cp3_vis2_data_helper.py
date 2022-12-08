import pandas as pd
import operator as op

interval_for_vis = 5


def read_data(district_num):
    if district_num == 9 or district_num == 14:
        path = 'District_9_and_14x.csv'
    elif district_num == 2 or district_num == 15:
        path = 'District_2_and_15x.csv'
    elif district_num == 5 or district_num == 18:
        path = 'District_5_and_18x.csv'
    elif district_num == 8 or district_num == 11:
        path = 'District_8_and_11x.csv'
    else:
        path = 'District_6_and_24x.csv'
    data = pd.read_csv(path)
    return data


def calculator(data, district_num):
    year_start = data['appointed_date'].sort_values()
    year_min = min(year_start)
    year_max = 2022

    year_interval = []
    for i in range(year_min, year_max, interval_for_vis):
        year_interval.append(i)

    black = [0] * len(year_interval)
    white = [0] * len(year_interval)
    asian = [0] * len(year_interval)
    hispanic = [0] * len(year_interval)
    unit = [district_num] * len(year_interval)

    for index, row in data.iterrows():
        start = int(row['appointed_date'])
        if pd.isna(row['resigned_time']):
            end = 2023
        else:
            end = int(row['resigned_time'])

        # Find which year interval start
        interval_index = (start - year_min) // interval_for_vis

        # Find which intervals are overlapped
        overlap = (end - start) // interval_for_vis

        if int(row['unit_name']) == district_num:
            if op.contains(row["race"], "Black"):
                for a in range(interval_index, interval_index + overlap + 1):
                    black[a] += 1
            elif op.contains(row["race"], "White"):
                for b in range(interval_index, interval_index + overlap + 1):
                    white[b] += 1
            elif op.contains(row["race"], "Asian"):
                for c in range(interval_index, interval_index + overlap + 1):
                    asian[c] += 1
            else:
                for d in range(interval_index, interval_index + overlap + 1):
                    hispanic[d] += 1

    df = pd.DataFrame({'year': year_interval, 'white': white, 'black': black, 'asian': asian, 'hispanic': hispanic,
                       'unit': unit})

    return df


if __name__ == "__main__":
    dataset = []
    for i in [9, 14, 8, 11, 6, 24, 5, 18, 2, 15]:
        csv = read_data(i)
        res = calculator(csv, i)
        dataset.append(res)
    result_data = pd.concat(dataset)

    result_data.to_csv('out.csv', header=True)


import pandas as pd
import numpy as np
from empath import Empath
import dask.dataframe as dd
import multiprocessing
import matplotlib.pyplot as plt
import requests
import time
from datetime import datetime


def simple_graph(df):
    # Graficamos
    ax = df.plot(
        figsize=(20, 10),
        kind="line",
        rot=45,
        linewidth=2)

    ax.grid()

    # Añadimos estilo a la gráfica
    ax.set_title(
        "Evolución de cada Dimensión Psicológica por Semanas",
        weight='bold'
    )
    ax.set_xlabel(
        "Semanas",
        weight='bold'
    )
    ax.set_ylabel(
        "Valor medio de cada Dimensión Psicológica",
        weight='bold'
    )


def grap_dimensions_and_covid(df1, df2):
    # Definimos el número de días a representar
    n_days = df1.shape[0]

    # Definimos los valores que queremos representar en cada eje
    x = np.arange(0, n_days, 1)
    y_ax1 = df1[
        [
            'smooth_depression',
            'smooth_anxiety',
            'smooth_suicide',
            'smooth_eating_disorder',
            'smooth_substance_abuse'
        ]
    ]
    y_ax2 = df2['7-Day Moving Avg']

    # Representamos los datos de sentimientos
    fig, ax1 = plt.subplots(figsize=(20, 10))
    ax1.plot(x, y_ax1)
    ax1.legend(
        [
            'depression',
            'anxiety',
            'suicide',
            'eating_disorder',
            'substance_abuse'
        ],
        loc='upper right')
    ax1.xaxis.grid(True)
    ax1.set_xlim(x.min(), x.max())

    # Definimos los xticks a representar
    xticks = np.arange(0, n_days, 14)
    xticks_labels = df1.index.astype(str).to_frame().iloc[xticks]

    # Añadimos estilo al eje x
    ax1.set_xticks(xticks)
    ax1.set_xticklabels(xticks_labels.datetime, rotation=60)

    # Instanciamos un segundo ax que comparte el eje x con el anterior
    ax2 = ax1.twinx()

    # Representamos los datos de covid
    ax2.plot(x, y_ax2, color='black')
    ax2.fill_between(x, y_ax2, color='gray', alpha=0.2)

    # Añadimos texto a la gráfica
    ax1.set_title(
        'Evolución de 5 Dimensiones Psicológicas en función de los Casos Diarios de Covid-19 (Enero 2020 - Julio 2021)',
        weight='bold'
    )
    ax1.set_ylabel(
        'Valor medio de cada Dimensión Psicológica',
        weight='bold'
    )
    ax2.set_ylabel(
        'Incidencia Acumulada a 7 Días (# Casos)',
        weight='bold'
    )


def grap_dimensions_and_covid_2(df1, df2):
    # Definimos el número de semanas a representar
    n_weeks = df1.shape[0]

    # Definimos los valores que queremos representar en cada eje
    x = np.arange(0, n_weeks, 1)
    y_ax1 = df1[
        [
            'depression',
            'anxiety',
            'suicide',
            'eating_disorder',
            'substance_abuse'
        ]
    ]
    y_ax2 = df2['7-Day Moving Avg']

    # Representamos los datos de sentimientos
    fig, ax1 = plt.subplots(figsize=(20, 10))
    ax1.plot(x, y_ax1)
    ax1.legend(
        [
            'depression',
            'anxiety',
            'suicide',
            'eating_disorder',
            'substance_abuse'
        ],
        loc='upper right')
    ax1.xaxis.grid(True)
    ax1.set_xlim(x.min(), x.max())

    # Definimos los xticks a representar
    xticks = np.arange(0, n_weeks, 2)
    xticks_labels = df1.index.astype(str).to_frame().iloc[xticks]

    # Añadimos estilo al eje x
    ax1.set_xticks(xticks)
    ax1.set_xticklabels(xticks_labels.datetime, rotation=60)

    # Instanciamos un segundo ax que comparte el eje x con el anterior
    ax2 = ax1.twinx()

    # Representamos los datos de covid
    ax2.plot(x, y_ax2, color='black')
    ax2.fill_between(x, y_ax2, color='gray', alpha=0.2)

    # Añadimos texto a la gráfica
    ax1.set_title(
        'Evolución de 5 Dimensiones Psicológicas en función de los Casos Diarios de Covid-19 (Enero 2020 - Julio 2021)',
        weight='bold'
    )
    ax1.set_ylabel(
        'Valor medio de cada Dimensión Psicológica',
        weight='bold'
    )
    ax2.set_ylabel(
        'Incidencia Acumulada a 7 Días (# Casos)',
        weight='bold'
    )


def get_pushshift_data(data_type, **kwargs):
    """
    Gets data from the PushShift API.
 
    data_type can be 'comment' or 'submission'
 
    Read more: https://github.com/pushshift/api
    """

    base_url = f"https://api.pushshift.io/reddit/search/{data_type}/"
    request = requests.get(base_url, params=kwargs)
    return request.json()


def timestamp_to_epoch(timestamp: str):
    return int((datetime.strptime(timestamp, "%d-%m-%Y") - datetime(1970, 1, 1)).total_seconds())


def pushshift_response_to_dict(pushshift_response: dict):
    output = {'comments': []}

    for comment in pushshift_response['data']:
        # Filtramos los comentarios que hayan sido eliminados
        if(comment['body'] != '[removed]' and comment['body'] != '[deleted]'):
            output['comments'].append(
                {
                    'author': comment['author'],
                    'subreddit': comment['subreddit'],
                    'body': comment['body'],
                    'created_utc': comment['created_utc']
                }
            )

    return output


def get_intervals(start_at, end_at, number_of_days_per_interval=1):
    intervals = []

    # 1 día = 86400 segundos
    period = (86400 * number_of_days_per_interval)
    end = start_at + period

    intervals.append((int(start_at), int(end)))

    while end <= end_at:
        start_at = end + 1
        end = (start_at - 1) + period
        intervals.append((int(start_at), int(end)))

    return intervals


def main():
    # Se debe especificar el directorio en el que se almacenan los datasets
    path_to_data = 'C:/Users/Andres/Documents/Data/MaBD/datasets'

    df_jan2020_may2021_us_empath = pd.read_csv(
        path_to_data + '/' + 'jan2020_may2021_us.csv',
        usecols=['id', 'username', 'tweet', 'date', 'language'],
        dtype=str
    )

    lexicon = Empath()

    # Definimos las dimensiones psicológicas con las que trabajar
    lexicon.create_category(
        "depression",
        ["depression", "mood", "adversity", "anguish"],
        model="reddit"
    )
    lexicon.create_category(
        "anxiety",
        ["anxiety", "stress", "worry", "fear"],
        model="reddit"
    )
    lexicon.create_category(
        "suicide",
        ["suicide", "suicidal", "self_harm", "self_damage", "suicidal_thoughts"],
        model="reddit"
    )
    lexicon.create_category(
        "eating_disorder",
        ["eating_disorder", "anorexia", "obesity", "bulimia"],
        model="reddit"
    )
    lexicon.create_category(
        "substance_abuse",
        ["substance_abuse", "addiction", "drugs", "alcoholism"],
        model="reddit"
    )

    categories = ['depression', 'anxiety', 'suicide',
                  'eating_disorder', 'substance_abuse']

    for category in categories:

        # Ejecutamos utilizando la librería Dask para minimizar el tiempo de cómputo
        df_jan2020_may2021_us_empath[category] = dd.from_pandas(
            df_jan2020_may2021_us_empath.tweet,
            npartitions=4 * multiprocessing.cpu_count()
        ).map_partitions(
            lambda dframe: dframe.apply(
                lambda x: lexicon.analyze(x, categories=[category])[category]
            )
        ).compute(scheduler='processes')

    # Primero convertimos la columna 'date' de nuestro DataFrame al formato 'datetime'
    df_jan2020_may2021_us_empath['datetime'] = pd.to_datetime(
        df_jan2020_may2021_us_empath.date) - pd.to_timedelta(7, unit='d')

    # Agrupamos a nivel de semana, estableciendo el primer día de la semana a lunes (argumento W-MON)
    jan2020_may2021_us_empath_by_weeks = df_jan2020_may2021_us_empath.resample(
        rule='W-MON', on='datetime')

    # Calculamos la media de los valores de cada dimensión psicológica para cada semana
    df_jan2020_may2021_us_empath_by_weeks = jan2020_may2021_us_empath_by_weeks.agg(
        {
            'depression': 'mean',
            'anxiety': 'mean',
            'suicide': 'mean',
            'eating_disorder': 'mean',
            'substance_abuse': 'mean'
        }
    )

    simple_graph(df_jan2020_may2021_us_empath_by_weeks)

    # Primero convertimos la columna 'date' de nuestro DataFrame al formato 'datetime'
    df_jan2020_may2021_us_empath['datetime'] = pd.to_datetime(
        df_jan2020_may2021_us_empath.date)

    # Agrupamos a nivel de día
    jan2020_may2021_us_empath_by_days = df_jan2020_may2021_us_empath.resample(
        rule='1D', on='datetime')

    # Calculamos la media de los valores para cada día
    df_jan2020_may2021_us_empath_by_days = jan2020_may2021_us_empath_by_days.agg(
        {
            'depression': 'mean',
            'anxiety': 'mean',
            'suicide': 'mean',
            'eating_disorder': 'mean',
            'substance_abuse': 'mean'
        }
    )

    simple_graph(df_jan2020_may2021_us_empath_by_days)

    categories = ['depression', 'anxiety', 'suicide',
                  'eating_disorder', 'substance_abuse']

    # Suavizamos el valor del cada dimensión psicológica
    for category in categories:
        df_jan2020_may2021_us_empath_by_days[f"smooth_{category}"] = df_jan2020_may2021_us_empath_by_days[category].rolling(
            7).mean()
        df_jan2020_may2021_us_empath_by_days[f"smooth_{category}"].fillna(
            df_jan2020_may2021_us_empath_by_days[category], inplace=True)

    simple_graph(
        df_jan2020_may2021_us_empath_by_days[
            [
                'smooth_depression',
                'smooth_anxiety',
                'smooth_suicide',
                'smooth_eating_disorder',
                'smooth_substance_abuse'
            ]
        ]
    )

    df_daily_case_trends_us = pd.read_csv(
        path_to_data + '/' + 'data_table_for_daily_case_trends__the_united_states.csv',
        usecols=['Date', '7-Day Moving Avg'],
        dtype={'Date': str, '7-Day Moving Avg': int}
    )

    # Formateamos el DataFrame con los datos sobre los casos de covid
    df_daily_case_trends_us['datetime'] = pd.to_datetime(
        df_daily_case_trends_us['Date'])
    df_daily_case_trends_us.drop(columns='Date', inplace=True)
    df_daily_case_trends_us.set_index('datetime', inplace=True)
    df_daily_case_trends_us.sort_index(inplace=True)

    # Definimos el primer y el último día para el que tenemos datos de sentimientos y de covid
    start_date = max(df_jan2020_may2021_us_empath_by_days.first_valid_index(
    ), df_daily_case_trends_us.first_valid_index())
    end_date = min(df_jan2020_may2021_us_empath_by_days.last_valid_index(
    ), df_daily_case_trends_us.last_valid_index())

    # Eliminamos los días que queden fuera de este rango
    df_jan2020_may2021_us_empath_by_days = df_jan2020_may2021_us_empath_by_days[
        df_jan2020_may2021_us_empath_by_days.index >= start_date]
    df_jan2020_may2021_us_empath_by_days = df_jan2020_may2021_us_empath_by_days[
        df_jan2020_may2021_us_empath_by_days.index <= end_date]
    df_daily_case_trends_us = df_daily_case_trends_us[df_daily_case_trends_us.index >= start_date]
    df_daily_case_trends_us = df_daily_case_trends_us[df_daily_case_trends_us.index <= end_date]

    grap_dimensions_and_covid(
        df_jan2020_may2021_us_empath_by_days, df_daily_case_trends_us)

    cities = [
        'nyc', 'seattle', 'losangeles', 'chicago', 'austin', 'portland', 'sanfrancisco',
        'boston', 'houston', 'atlanta', 'philadelphia', 'denver', 'dallas', 'washingtondc',
        'sandiego', 'pittsburgh', 'phoenix', 'minneapolis', 'orlando', 'nashville', 'stlouis'
    ]
    states = [
        'texas', 'california', 'newjersey', 'michigan', 'minnesota', 'colorado', 'wisconsin',
        'florida', 'connecticut', 'oregon', 'ohio', 'hawaii', 'northcarolina', 'oklahoma',
        'maryland', 'arizona', 'virginia', 'iowa', 'maine', 'indiana', 'georgia', 'alaska'
    ]

    # Juntamos ambas listas en una única lista
    subreddits = cities + states

    comments = []
    for subreddit in subreddits:
        # Definimos los intervalos que vamos a usar
        intervals = get_intervals(timestamp_to_epoch(
            '23-01-2020'), timestamp_to_epoch('22-07-2021'), 7)

        for interval in intervals:
            try:
                data = get_pushshift_data(
                    data_type='comment',
                    subreddit=subreddit,
                    after=interval[0],
                    before=interval[1],
                    size=500
                )
                time.sleep(.5)

                data = pushshift_response_to_dict(data)
                comments.extend(data['comments'])
            except:
                print("Error")

    # Convertimos el resultado a un objeto del tipo DataFrame
    df_jan2020_jul2021_us_reddit = pd.DataFrame(comments)

    categories = ['depression', 'anxiety', 'suicide',
                  'eating_disorder', 'substance_abuse']

    for category in categories:

        # Ejecutamos utilizando la librería Dask para minimizar el tiempo de cómputo
        df_jan2020_jul2021_us_reddit[category] = dd.from_pandas(
            df_jan2020_jul2021_us_reddit.body,
            npartitions=4 * multiprocessing.cpu_count()
        ).map_partitions(
            lambda dframe: dframe.apply(
                lambda x: lexicon.analyze(
                    str(x), categories=[category])[category]
            )
        ).compute(scheduler='processes')

    # Primero convertimos la columna 'created_utc' de nuestro DataFrame al formato 'datetime'
    df_jan2020_jul2021_us_reddit['datetime'] = df_jan2020_jul2021_us_reddit['created_utc'].apply(
        lambda x: datetime.utcfromtimestamp(x) - pd.to_timedelta(7, unit='d')
    )

    # Agrupamos a nivel de semana
    df_jan2020_jul2021_us_reddit_by_weeks = df_jan2020_jul2021_us_reddit.resample(
        rule='W-MON', on='datetime')

    # Calculamos la media de los valores para cada semana
    df_jan2020_jul2021_us_reddit_by_weeks = df_jan2020_jul2021_us_reddit_by_weeks.agg(
        {
            'depression': 'mean',
            'anxiety': 'mean',
            'suicide': 'mean',
            'eating_disorder': 'mean',
            'substance_abuse': 'mean'
        }
    )

    df_jan2020_jul2021_us_reddit_by_weeks = df_jan2020_jul2021_us_reddit_by_weeks.fillna(
        df_jan2020_jul2021_us_reddit_by_weeks.mean()
    )

    simple_graph(
        df_jan2020_jul2021_us_reddit_by_weeks
        [
            [
                'depression',
                'anxiety',
                'suicide',
                'eating_disorder',
                'substance_abuse'
            ]
        ]
    )

    df_daily_case_trends_us = pd.read_csv(
        path_to_data + '/' + 'data_table_for_daily_case_trends__the_united_states.csv',
        usecols=['Date', '7-Day Moving Avg'],
        dtype={'Date': str, '7-Day Moving Avg': int}
    )

    # Formateamos el DataFrame con los datos sobre los casos de covid
    df_daily_case_trends_us['datetime'] = pd.to_datetime(
        df_daily_case_trends_us['Date'])
    df_daily_case_trends_us.drop(columns='Date', inplace=True)

    # Agrupamos a nivel de semana los casos de covid
    df_daily_case_trends_us_by_weeks = df_daily_case_trends_us.resample(
        rule='W-MON', on='datetime')

    # Calculamos la media de los valores para cada semana
    df_daily_case_trends_us_by_weeks = df_daily_case_trends_us_by_weeks.agg(
        {'7-Day Moving Avg': 'mean'})

    # Definimos el primer y el último día para el que tenemos datos de sentimientos y de covid
    start_date = max(df_jan2020_jul2021_us_reddit_by_weeks.first_valid_index(
    ), df_daily_case_trends_us_by_weeks.first_valid_index())
    end_date = min(df_jan2020_jul2021_us_reddit_by_weeks.last_valid_index(
    ), df_daily_case_trends_us_by_weeks.last_valid_index())

    # Eliminamos los días que queden fuera de este rango
    df_jan2020_jul2021_us_reddit_by_weeks = df_jan2020_jul2021_us_reddit_by_weeks[
        df_jan2020_jul2021_us_reddit_by_weeks.index >= start_date]
    df_jan2020_jul2021_us_reddit_by_weeks = df_jan2020_jul2021_us_reddit_by_weeks[
        df_jan2020_jul2021_us_reddit_by_weeks.index <= end_date]
    df_daily_case_trends_us_by_weeks = df_daily_case_trends_us_by_weeks[
        df_daily_case_trends_us_by_weeks.index >= start_date]
    df_daily_case_trends_us_by_weeks = df_daily_case_trends_us_by_weeks[
        df_daily_case_trends_us_by_weeks.index <= end_date]

    grap_dimensions_and_covid_2(
        df_jan2020_jul2021_us_reddit_by_weeks, df_daily_case_trends_us_by_weeks)


if __name__ == '__main__':
    main()

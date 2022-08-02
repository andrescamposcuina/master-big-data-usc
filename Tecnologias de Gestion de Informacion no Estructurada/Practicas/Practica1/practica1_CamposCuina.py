import twint
import nest_asyncio
import pandas as pd
import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer
import nltk
from nltk.corpus import stopwords
import re
from vaderSentiment.vaderSentiment import SentimentIntensityAnalyzer
import dask.dataframe as dd
import multiprocessing
import matplotlib.pyplot as plt
from matplotlib.collections import LineCollection
from matplotlib.colors import LinearSegmentedColormap

# Necesario para que no se quede colgado durante la búsqueda mediante Twint
nest_asyncio.apply()


def graph_sentiment_evolution(df: pd.DataFrame):
    n_days = df.shape[0]

    # Definimos los valores que queremos representar en cada eje
    x = np.arange(0, n_days, 1)
    y = df['smooth_compound']

    # Definimos un gradiente de color del rojo al verde
    cmap = LinearSegmentedColormap.from_list("", [(1, 0, 0), (0, 1, 0)])

    # Definimos los segmentos a representar
    points = np.array([x, y]).T.reshape(-1, 1, 2)
    segments = np.concatenate([points[:-2], points[1:-1], points[2:]], axis=1)

    # Le asignamos un color a cada uno de los segmentos en función de los valores del eje y
    lc = LineCollection(segments, cmap=cmap, linewidth=2)
    lc.set_array(y)

    # Graficamos
    fig, ax = plt.subplots(figsize=(20, 10), ncols=1, nrows=1)
    ax.add_collection(lc)
    ax.grid()
    ax.autoscale()
    ax.set_xlim(x.min(), x.max())

    # Definimos los xticks a representar
    xticks = np.arange(0, n_days, 14)
    xticks_labels = df.index.astype(
        str).to_frame().iloc[xticks]

    # Añadimos estilo a los ejes
    ax.set_yticks(np.arange(y.min(), y.max(), 0.01))
    ax.set_xticks(xticks)
    ax.set_xticklabels(xticks_labels.datetime, rotation=60)

    # Añadimos texto a la gráfica
    ax.set_title(
        "Evolución del Sentimiento (Enero 2020 - Julio 2021)", weight='bold')
    ax.set_ylabel("Valor del Compound", weight='bold')


def grap_sentiment_and_covid(df1: pd.DataFrame, df2: pd.DataFrame):
    # Definimos el número de días a representar
    n_days = df1.shape[0]

    # Definimos los valores que queremos representar en cada eje
    x = np.arange(0, n_days, 1)
    y_ax1 = df1['smooth_compound']
    y_ax2 = df2['7-Day Moving Avg']

    # Definimos un gradiente de color del rojo al verde
    cmap = LinearSegmentedColormap.from_list("", [(1, 0, 0), (0, 1, 0)])

    # Definimos los segmentos a representar
    points = np.array([x, y_ax1]).T.reshape(-1, 1, 2)
    segments = np.concatenate([points[:-2], points[1:-1], points[2:]], axis=1)

    # Le asignamos un color a cada uno de los segmentos en función de los valores del eje y
    lc = LineCollection(segments, cmap=cmap, linewidth=2)
    lc.set_array(y_ax1)

    # Representamos los datos de sentimientos
    fig, ax1 = plt.subplots(figsize=(20, 10), ncols=1, nrows=1)
    ax1.add_collection(lc)
    ax1.xaxis.grid(True)
    ax1.autoscale()
    ax1.set_xlim(x.min(), x.max())

    # Definimos los xticks a representar
    xticks = np.arange(0, n_days, 14)
    xticks_labels = df1.index.astype(
        str).to_frame().iloc[xticks]

    # Añadimos estilo al eje x
    ax1.set_xticks(xticks)
    ax1.set_xticklabels(xticks_labels.datetime, rotation=60)

    # Instanciamos un segundo ax que comparte el eje x con el anterior
    ax2 = ax1.twinx()

    # Representamos los datos de covid
    ax2.plot(x, y_ax2, color='orange')
    ax2.fill_between(x, y_ax2, color='orange', alpha=0.2)
    ax2.autoscale()

    # Añadimos texto a la gráfica
    ax1.set_title(
        "Evolución del Sentimiento en función de los Casos Diarios de Covid-19 (Enero 2020 - Julio 2021)", weight='bold')
    ax1.set_ylabel("Valor del Compound", weight='bold')
    ax2.set_ylabel('Incidencia Acumulada a 7 Días (# Casos)', weight='bold')


def main():
    # Se debe especificar el directorio en el que se almacenan los datasets
    path_to_data = 'C:/Users/Andres/Documents/Data/MaBD/datasets'

    # # Configuramos la búsqueda de tweets
    # c = twint.Config()
    # c.Search = "Afghanistan"
    # c.Output = path_to_data + '/' + 'afghanistan.csv'
    # c.Store_csv = True
    # c.Lang = "en"
    # c.Limit = 150000

    # # Ejecutamos la búsqueda
    # twint.run.Search(c)

    df_tweets = pd.read_csv(
        path_to_data + '/' + 'afghanistan.csv',
        usecols=['id', 'username', 'tweet', 'date', 'language'],
        dtype=str
    )

    df_tweets = df_tweets[df_tweets.language == 'en']

    # Definimos el corpus a utilizar a partir del DataFrame definido previamente
    corpus = df_tweets.tweet.to_list()

    # Recorremos el corpus y eliminamos de cada tweet las URL existentes
    corpus = [re.sub(r'https?:\/\/[^ ]*', '', tweet, flags=re.MULTILINE)
              for tweet in corpus]

    # Por si acaso, eliminamos los tweets que quedaron vacíos (contenían solo una URL)
    corpus = [tweet for tweet in corpus if tweet != '']

    # Es necesario descargar las stopwords la primera que se vayan a utilizar
    nltk.download("stopwords")

    vectorizer = TfidfVectorizer(
        stop_words=stopwords.words('english'),
        strip_accents='unicode',
        min_df=10,
        use_idf=True
    )
    X = vectorizer.fit_transform(corpus)

    ## Creamos el DataFrame
    X_df = pd.DataFrame(X.toarray(), columns=vectorizer.get_feature_names())

    # Definimos el número de palabras más centrales que queremos consultar
    n_words_to_retrieve = 50

    # Sumamos el valor TF-IDF de cada palabra
    X_sum_by_column = np.array(np.sum(X, axis=0)).flatten()

    # Obtenemos los índices de las n_words_to_retrieve palabras más centrales
    indices = (-X_sum_by_column).argsort()[:n_words_to_retrieve]

    # Obtenemos las palabras
    words1 = np.take(vectorizer.get_feature_names(), indices)
    print(words1)

    vectorizer = TfidfVectorizer(
        stop_words=stopwords.words('english'),
        strip_accents='unicode',
        min_df=10,
        use_idf=False
    )
    X = vectorizer.fit_transform(corpus)

    # Definimos el número de palabras más repetidas que queremos consultar
    n_words_to_retrieve = 100

    # Sumamos el valor TF de cada palabra
    X_sum_by_column = np.array(np.sum(X, axis=0)).flatten()

    # Obtenemos los índices de las n_words_to_retrieve palabras más repetidas
    indices = (-X_sum_by_column).argsort()[:n_words_to_retrieve]

    # Obtenemos las palabras
    words2 = np.take(vectorizer.get_feature_names(), indices)
    print(words2)

    # Se debe especificar el directorio en el que se almacenan los datasets
    path_to_data = 'C:/Users/Andres/Documents/Data/MaBD/datasets/US_data'

    df_jan2020_jul2020_us = pd.read_csv(
        path_to_data + '/' + 'jan2020_jul2020_us.csv',
        usecols=['id', 'username', 'tweet', 'date', 'language'],
        dtype=str
    )

    df_jul2020_may2021_us = pd.read_csv(
        path_to_data + '/' + 'jul2020_may2021_us.csv',
        usecols=['id', 'username', 'tweet', 'date', 'language'],
        dtype=str
    )

    df_jan2020_may2021_us = pd.concat(
        [df_jan2020_jul2020_us, df_jul2020_may2021_us],
        axis=0,
        ignore_index=True
    )

    df_jan2020_may2021_us = df_jan2020_may2021_us[df_jan2020_may2021_us.language == 'en']

    # Recorremos el corpus y eliminamos de cada tweet las URL existentes
    df_jan2020_may2021_us['tweet'] = [re.sub(
        r'https?:\/\/[^ ]*', '', tweet, flags=re.MULTILINE) for tweet in df_jan2020_may2021_us.tweet]

    # Por si acaso, eliminamos los tweets que quedaron vacíos (contenían solo una URL)
    df_jan2020_may2021_us['tweet'] = [
        tweet for tweet in df_jan2020_may2021_us.tweet if tweet != '']

    analyzer = SentimentIntensityAnalyzer()

    # Ejecutamos utilizando la librería Dask para minimizar el tiempo de cómputo
    df_jan2020_may2021_us['compound'] = dd.from_pandas(
        df_jan2020_may2021_us.tweet,
        npartitions=4*multiprocessing.cpu_count()
    ).map_partitions(
        lambda dframe: dframe.apply(
            lambda x: analyzer.polarity_scores(x)['compound']
        )
    ).compute(scheduler='processes')

    # Primero convertimos la columna 'date' de nuestro DataFrame al formato 'datetime'
    df_jan2020_may2021_us['datetime'] = pd.to_datetime(
        df_jan2020_may2021_us.date)

    # Agrupamos a nivel de día
    jan2020_may2021_us_by_days = df_jan2020_may2021_us.resample(
        rule='1D', on='datetime')

    # Calculamos la media de los valores del compound para cada día
    jan2020_may2021_us_by_days = jan2020_may2021_us_by_days.compound.mean()
    df_jan2020_may2021_us_by_days = jan2020_may2021_us_by_days.to_frame()

    # Suavizamos el valor del 'compound'
    df_jan2020_may2021_us_by_days['smooth_compound'] = df_jan2020_may2021_us_by_days['compound'].rolling(
        3).mean()
    df_jan2020_may2021_us_by_days['smooth_compound'].fillna(
        df_jan2020_may2021_us_by_days['compound'], inplace=True)

    graph_sentiment_evolution(df_jan2020_may2021_us_by_days)

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
    start_date = max(jan2020_may2021_us_by_days.first_valid_index(),
                     df_daily_case_trends_us.first_valid_index())
    end_date = min(jan2020_may2021_us_by_days.last_valid_index(),
                   df_daily_case_trends_us.last_valid_index())

    # Eliminamos los días que queden fuera de este rango
    df_jan2020_may2021_us_by_days = df_jan2020_may2021_us_by_days[
        df_jan2020_may2021_us_by_days.index >= start_date]
    df_jan2020_may2021_us_by_days = df_jan2020_may2021_us_by_days[
        df_jan2020_may2021_us_by_days.index <= end_date]
    df_daily_case_trends_us = df_daily_case_trends_us[df_daily_case_trends_us.index >= start_date]
    df_daily_case_trends_us = df_daily_case_trends_us[df_daily_case_trends_us.index <= end_date]

    # Mostramos la gráfica
    grap_sentiment_and_covid(df_jan2020_may2021_us_by_days, df_daily_case_trends_us)


if __name__ == '__main__':
    main()

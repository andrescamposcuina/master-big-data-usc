# EJERCICIO 3

# Cargar las librerías necesarias
library(readxl)
library(dplyr)

# Leer el dataset desde el archivo Excel
setwd("C:/Users/roque/OneDrive/Escritorio/ACUE/Examen")
data <- read_excel("TT_dataset_compras.xlsx")

# Mostrar el dataset
print(data)

# Excluir la primera columna (transaction ID)
data <- data %>% select(-`transaction ID`)

# Calcular la suma de cada columna
sums <- colSums(data)

# Calcular la preferencia del usuario dividiendo cada suma por el número de filas
preferences <- sums / nrow(data)

# Mostrar las preferencias del usuario
print(preferences)

# EJERCICIO 1

# Lectura de datos
setwd("C:/Users/roque/OneDrive/Escritorio/ACUE/Examen")
data <- read.csv2("acue_examen_dataset_modificado.csv", header = TRUE, sep = ",", quote = "\"")
data

# Filtramos el conjunto de datos
t1_ratings <- subset(data, tapaID == "t1")
u31_ratings <- subset(data, userID == "u31")

# RECOMENDADOR COLABORATIVO
# Solo tenemos los ratings de diferentes usuarios sobre la tapa1, por lo que 
# la predicción sobre la puntuacion que el u31 le dará a la tapa1 será la media 
# de las valoraciones de los restantes usuarios sobre dicha tapa
mean_t1_rating <- mean(t1_ratings$tapaRating, na.rm = TRUE)
cat("Predicción basada en el enfoque colaborativo: ", mean_t1_rating, "\n")

# RECOMENDADOR BASADO EN CONTENIDO
# Solo tenemos la variable characterTapa para hacer nuestra predicción, por lo que
# la predicción será la media de las valoraciones de las tapas que tienen el mismo
# valor de characterTapa que la tapa a predecir (Daring)
character_t1 <- t1_ratings$characterTapa[1] # Suponiendo que todas las tapas t1 tienen el mismo carácter
content_ratings_u31 <- subset(u31_ratings, characterTapa == character_t1)
mean_content_rating_u31 <- mean(content_ratings_u31$tapaRating, na.rm = TRUE)
cat("Predicción basada en el enfoque de contenido: ", mean_content_rating_u31, "\n")
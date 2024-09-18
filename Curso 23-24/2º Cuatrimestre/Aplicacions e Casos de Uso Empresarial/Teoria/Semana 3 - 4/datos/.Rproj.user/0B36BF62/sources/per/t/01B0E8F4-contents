# Ejercicio 4
library(recommenderlab)
data(Jester5k)
Jester5k

#Inspecciona las propiedades del dataset Jester5k
# Estructura del dataframe
str(Jester5k)
# Resumen estadístico del dataframe
summary(Jester5k)
# Dimensiones del dataframe
dim(Jester5k)
# Conteo de valores faltantes por columna
colSums(is.na(Jester5k))

# --------------- 5.5 --------------------
# Visualizar las primeras 100 filas y columnas de la matriz de calificaciones
image(Jester5k[1:100, 1:100])

#REcomnendador con todos los datos
# Cargar el dataset Jester5k
data(Jester5k)

# Configurar el modelo de recomendación. Puedes cambiar el método si el tutorial especifica otro.
recommender_model_full <- Recommender(Jester5k, method = "UBCF")

# Hacer predicciones para los usuarios 1001 y 1002
recommendations_full <- predict(recommender_model_full, Jester5k[1001:1002], n=5)
as(recommendations_full, "list")

#REcomnendador con 100 primeros
# Crear un subconjunto con los primeros 100 usuarios
Jester5k_subset <- Jester5k[1:100]

# Configurar el modelo de recomendación para el subconjunto
recommender_model_subset <- Recommender(Jester5k_subset, method = "UBCF")

# Hacer predicciones para los mismos usuarios (1001 y 1002) utilizando el modelo del subconjunto
recommendations_subset <- predict(recommender_model_subset, Jester5k[1001:1002], n=5)
as(recommendations_subset, "list")

# --------------- 5.6 --------------------
# Configurar el esquema de evaluación
e <- evaluationScheme(Jester5k[1:1000], method="split", train=0.9, given=15, goodRating=5)

# Crear recomendadores
r1 <- Recommender(getData(e, "train"), "UBCF")
r2 <- Recommender(getData(e, "train"), "IBCF")

# Computar las calificaciones predichas
p1 <- predict(r1, getData(e, "known"), type="ratings")
p2 <- predict(r2, getData(e, "known"), type="ratings")

# Calcular el error
error <- rbind(
  calcPredictionAccuracy(p1, getData(e, "unknown")),
  calcPredictionAccuracy(p2, getData(e, "unknown"))
)
rownames(error) <- c("UBCF","IBCF")
error


# --------------- 5.7 --------------------
# Configurar el esquema de evaluación
scheme <- evaluationScheme(Jester5k[1:1000], method="cross", k=4, given=3, goodRating=5)

# Evaluar el método recomendador
results <- evaluate(scheme, method="POPULAR", n=c(1,3,5,10,15,20))

# Obtener y visualizar los resultados
avg_results <- avg(results)
plot(results, annotate=TRUE)
plot(results, "prec/rec", annotate=TRUE)


# --------------- 5.8 --------------------
# Configurar el esquema de evaluación
scheme <- evaluationScheme(Jester5k[1:1000], method="split", train=.9, k=1, given=20, goodRating=5)

# Lista de algoritmos a comparar
algorithms <- list(
  "random items" = list(name="RANDOM", param=NULL),
  "popular items" = list(name="POPULAR", param=NULL),
  "user-based CF" = list(name="UBCF", param=list(method="Cosine", nn=50, minRating=5))
  # Puedes agregar más algoritmos aquí si lo deseas
)

# Ejecutar los algoritmos y obtener resultados
results <- evaluate(scheme, algorithms, n=c(1, 3, 5, 10, 15, 20))

# Ver los resultados
results

# Plot ROC y precision-recall plots
plot(results, annotate=c(1,3), legend="topleft")
plot(results, "prec/rec", annotate=3)


#Comparacion con menos datos
# Binarizar el dataset Jester5k
Jester_binary <- binarize(Jester5k, minRating=5)
Jester_binary <- Jester_binary[rowCounts(Jester_binary)>20]

# Configurar el esquema de evaluación para el dataset binarizado
scheme_binary <- evaluationScheme(Jester_binary[1:1000], method="split", train=.9, k=1, given=20)

# Lista de algoritmos para el dataset binarizado
algorithms_binary <- list(
  "random items" = list(name="RANDOM", param=NULL),
  "popular items" = list(name="POPULAR", param=NULL),
  "user-based CF" = list(name="UBCF", param=list(method="Jaccard", nn=50))
  # Puedes agregar más algoritmos aquí si lo deseas
)

# Ejecutar los algoritmos y obtener resultados para el dataset binarizado
results_binary <- evaluate(scheme_binary, algorithms_binary, n=c(1,3,5,10,15,20))

# Plot ROC y precision-recall plots para el dataset binarizado
plot(results_binary, annotate=c(1,3), legend="bottomright")


# --------------- 5 --------------------
# Cargar el paquete recommenderlab y el dataset MovieLense
library(recommenderlab)
data(MovieLense)

# Inspeccionar las propiedades del dataset MovieLense
str(MovieLense)
summary(MovieLense)
dim(MovieLense)
colSums(is.na(MovieLense))

# Filtrar para usuarios con más de 100 calificaciones
MovieLense100 <- MovieLense[rowCounts(MovieLense) > 100,]

# Dividir en conjuntos de entrenamiento y prueba
train_set <- MovieLense100[1:100]
test_set <- MovieLense100[101:200]

# Configurar el esquema de evaluación
evaluation_scheme <- evaluationScheme(train_set, method="split", train=.9, given=10, goodRating=4)

# Lista de algoritmos a comparar
algorithms <- list(
  "RANDOM" = list(name="RANDOM", param=NULL),
  "POPULAR" = list(name="POPULAR", param=NULL),
  "UBCF" = list(name="UBCF", param=list(nn=50)),
  "IBCF" = list(name="IBCF", param=list(k=30))
)

# Realizar la evaluación
results <- evaluate(evaluation_scheme, algorithms, n=c(1, 3, 5, 10, 15, 20))


# Gráfica ROC
plot(results, annotate=TRUE)

# Gráfica de Precisión-Recall
plot(results, "prec/rec", annotate=TRUE)

# Operaciones básicas
3+3
3-3
3*3
3^3
3**3

# Funciones básicas
log(3)
sqrt(3)

# Cargar datos de email/spam
install.packages("openintro")
library(openintro)
head(email)

email$spam
# Tamaño de vector
length(email$spam)

# Tabla de frecuencias absolutas
table(email$spam)

# Ayuda
?email
help(email)

# Tabla de frecuencias relativas
table(email$spam)/length(email$spam)

# Gráfico de barras
barplot(table(email$spam))
# Gráfico de tarta/sectores
pie(table(email$spam))

# Histograma
hist(email$num_char)

# Diagrama de caja
boxplot(email$num_char)

# Media
mean(email$num_char)
# Mediana
median(email$num_char)

# Varianza
var(email$num_char)
# Desviación típica
sqrt(var(email$num_char))
sd(email$num_char)

# Asimetría
install.packages("moments")
library(moments)
skewness(email$num_char)

# Cuantiles
quantile(email$num_char,0.01)

# Diagrama de dispersión
plot(email$num_char,email$line_breaks)
# Regresión lineal
reglin=lm(email$line_breaks~email$num_char)
abline(reglin,col=2,lwd=2)

# Guardar un elemento
elem=3
elem<-3
elem*4
# R disting mayus y minus
Elem
elem

# Crear vectores
vect<-c(3,2,4)
# R hace oper elem a elem
3*vect
# Si queremos acceder a un elemnto del vector
vect[2]
vect[c(1,3)]
# Eliminar objeto
rm(elem)
elem

# Secuencias de números
seq(1,10,len=5)
seq(1,10,by=5)

# Matrices
mat=matrix(c(1,3,5,7),nrow=2,ncol=2)
mat[2,2]
mat[2,]
mat[,2]
dim(mat)
mat[,-2]

vect<-c(3,2,4)
vect[1]

for(i in 1:2){
  mat[i,1]=mat[i,1]+1
}

sum(vect)

mat*mat
mat%*%mat

vect2=c("Si","No","Si")

# Cargar datos

# Cambiar directorio de trabajo
setwd("C:/Users/jose.ameijeiras/Downloads")

# Cargar datos de advertising
datos=read.csv("Advertising.csv")
hist(datos$Sales)

# read.csv read.table
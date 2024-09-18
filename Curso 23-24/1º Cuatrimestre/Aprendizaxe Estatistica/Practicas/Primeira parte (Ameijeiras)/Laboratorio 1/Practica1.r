# Libreria para formatear os datos
library(tidyr)

# Libreria para a simetria
library(moments)

# Cargamos os datos e transformamolos na estructura desexada
datos <- read.csv("Datos_Sociedades.csv", header = TRUE, sep = ";")
datos <- pivot_wider(datos,
                     id_cols = c("Lugar", "Periodo"),
                     names_from = "Medida",
                     values_from = "Valor")

# Seleccionamos o subonxunto de datos "galicia_con2020" para Galicia entre os anos 2009 e 2022
galicia_con2020 <- datos[datos$Lugar == "12 Galicia" & datos$Periodo >= 2009 & datos$Periodo <= 2022, ]
galicia_con2020

# Seleccionamos o subonxunto de datos "galicia_con2020" para Galicia entre os anos 2009 e 2022, excluíndo o ano 2020
galicia_sen2020 <- galicia_con2020[galicia_con2020$Periodo != 2020, ]

# Estudamos as dimensions de cada subconxunto
length(galicia_con2020)
nrow(galicia_con2020)

length(galicia_sen2020)
nrow(galicia_sen2020)

# A continuacion facemos un estudio exploratorio dos datos

# Numero de Sociedades en galicia_con2020
summary(galicia_con2020$NumeroSociedades)
sd(galicia_con2020$NumeroSociedades)
skewness(galicia_con2020$NumeroSociedades)

# Capital Suscrito en galicia_con2020 (miles de euros)
summary(galicia_con2020$CapitalSuscrito)
sd(galicia_con2020$CapitalSuscrito)
skewness(galicia_con2020$CapitalSuscrito)

# Capital Desembolsado en galicia_con2020 (miles de euros)
summary(galicia_con2020$CapitalDesembolsado)
sd(galicia_con2020$CapitalDesembolsado)
skewness(galicia_con2020$CapitalDesembolsado)

# Numero de Sociedades en galicia_sen2020 sen o ano 2020 
summary(galicia_sen2020$NumeroSociedades)
sd(galicia_sen2020$NumeroSociedades)
skewness(galicia_sen2020$NumeroSociedades)

# Capital Suscrito en galicia_sen2020 sen o ano 2020 (miles de euros)
summary(galicia_sen2020$CapitalSuscrito)
sd(galicia_sen2020$CapitalSuscrito)
skewness(galicia_sen2020$CapitalSuscrito)

# Capital Desembolsado en galicia_sen2020 sen o ano 2020 (miles de euros)
summary(galicia_sen2020$CapitalDesembolsado)
sd(galicia_sen2020$CapitalDesembolsado)
skewness(galicia_sen2020$CapitalDesembolsado)


# A continuacion realizamos a representacion visual dos datos

# Histograma do Numero de Sociedades con e sen o ano 2020
hist(galicia_con2020$NumeroSociedades, col = "red",
    xlab = "Número de Sociedades", ylab = "Frecuencia", main = "Histograma do Número de Sociedades",
    cex.lab = 1.5, cex.main = 1.5
)
hist(galicia_sen2020$NumeroSociedades, col = "blue", add = TRUE)
legend("topleft", legend = "2020", col = "red", fill = "red", cex = 1.25)


# Histograma do Capital Desembolsado con e sen o ano 2020
hist(galicia_con2020$CapitalDesembolsado, col = "red",
    xlab = "Capital Desembolsado (miles de euros)", ylab = "Frecuencia", main = "Histograma do Capital Desembolsado",
    cex.lab = 1.5, cex.main = 1.5
)
hist(galicia_sen2020$CapitalDesembolsado, col = "blue", add = TRUE)
legend("topright", legend = "2020", col = "red", fill = "red", cex = 1.25)

# Grafico de liñas comparando o Numero de Sociedades en Galicia con e sen o ano 2020
plot(galicia_con2020$Periodo, galicia_con2020$NumeroSociedades, type = "l", col = "red",
    xlab = "Ano", ylab = "Número de Sociedades", main = "Evolución do Número de Sociedades en Galicia",
    cex.lab = 1.5, cex.main = 1.5
)
lines(galicia_sen2020$Periodo, galicia_sen2020$NumeroSociedades, col = "blue")
legend("topright", legend = "2020", col = "red", fill = "red", cex = 1.25)


# Grafico de liñas comparando o Capital Desembolsado en Galicia con y sin o ano 2020
plot(galicia_con2020$Periodo, galicia_con2020$CapitalDesembolsado, type = "l", col = "red",
    xlab = "Ano", ylab = "Capital Desembolsado", main = "Evolución do Capital Desembolsado en Galicia (en miles de euros)",
    cex.lab = 1.5, cex.main = 1.5
)
lines(galicia_sen2020$Periodo, galicia_sen2020$CapitalDesembolsado, col = "blue")
legend("topright", legend = "2020", col = "red", fill = "red", cex = 1.25)


# Inferencia
t.test(galicia_con2020$NumeroSociedades, galicia_sen2020$NumeroSociedades, conf.level = 0.95)
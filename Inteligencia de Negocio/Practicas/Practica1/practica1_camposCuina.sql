CREATE TABLE tiempo (
    id SERIAL NOT NULL,
    ano INT NOT NULL,
    mes INT NOT NULL,
    mes_texto VARCHAR(16) NOT NULL,
    CONSTRAINT tiempo_pk PRIMARY KEY (id)
);

CREATE TABLE director (
    id SERIAL NOT NULL,
    text_id VARCHAR(1000) NOT NULL,
    nombre VARCHAR(1000) NOT NULL,
    CONSTRAINT director_pk PRIMARY KEY (id)
);

CREATE TABLE productor (
    id SERIAL NOT NULL,
    text_id VARCHAR(1000) NOT NULL,
    nombre VARCHAR(1000) NOT NULL,
    CONSTRAINT productor_pk PRIMARY KEY (id)
);

CREATE TABLE productora (
    id SERIAL NOT NULL,
    text_id INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    CONSTRAINT productora_pk PRIMARY KEY (id)
);

CREATE TABLE finanzas (
    tiempo INT,
    director INT,
    productor INT,
    productora INT,
    coste INT DEFAULT 0,
    ingresos INT DEFAULT 0,
    CONSTRAINT finanzas_pk PRIMARY KEY (tiempo, director, productor, productora),
    CONSTRAINT tiempo_finanzas_fk FOREIGN KEY (tiempo) REFERENCES tiempo(id) ON DELETE restrict ON UPDATE cascade,
    CONSTRAINT director_finanzas_fk FOREIGN KEY (director) REFERENCES director(id) ON DELETE cascade ON UPDATE cascade,
    CONSTRAINT productor_finanzas_fk FOREIGN KEY (productor) REFERENCES productor(id) ON DELETE cascade ON UPDATE cascade,
    CONSTRAINT productora_finanzas_fk FOREIGN KEY (productora) REFERENCES productora(id) ON DELETE cascade ON UPDATE cascade
);

CREATE TABLE satisfaccion_usuarios (
    tiempo_votacion INT,
    tiempo_emision INT,
    director INT,
    productor INT,
    productora INT,
    votos INT DEFAULT 0,
    satisfaccion DECIMAL(2, 1),
    CONSTRAINT satisfaccion_usuarios_pk PRIMARY KEY (tiempo_votacion, tiempo_emision, director, productor, productora),
    CONSTRAINT tiempo_votacion_satisfaccion_usuarios_fk FOREIGN KEY (tiempo_votacion) REFERENCES tiempo(id) ON DELETE restrict ON UPDATE cascade,
    CONSTRAINT tiempo_emision_satisfaccion_usuarios_fk FOREIGN KEY (tiempo_emision) REFERENCES tiempo(id) ON DELETE restrict ON UPDATE cascade,
    CONSTRAINT director_satisfaccion_usuarios_fk FOREIGN KEY (director) REFERENCES director(id) ON DELETE cascade ON UPDATE cascade,
    CONSTRAINT productor_satisfaccion_usuarios_fk FOREIGN KEY (productor) REFERENCES productor(id) ON DELETE cascade ON UPDATE cascade,
    CONSTRAINT productora_satisfaccion_usuarios_fk FOREIGN KEY (productora) REFERENCES productora(id) ON DELETE cascade ON UPDATE cascade
);

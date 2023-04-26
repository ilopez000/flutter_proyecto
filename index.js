const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const mysql = require('mysql');
const jwt = require('jsonwebtoken');
const app = express();
const PORT = 3000;

app.use(bodyParser.json());
app.use(cors());

const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'proyecto_flutter',
});

db.connect((err) => {
    if (err) throw err;
    console.log('Conectado a la base de datos MySQL');
});

app.post('/proyecto_flutter/login', (req, res) => {
    const email = req.body.email;
    const password = req.body.password;

    const query = 'SELECT * FROM users WHERE email = ?';
    db.query(query, [email], (err, results) => {
        if (err) throw err;

        if (results.length === 0) {
            return res.json({ success: false, message: 'Correo electrónico o contraseña incorrectos' });
        }

        const user = results[0];

        if (password === user.password) {
            const token = jwt.sign({ id: user.id }, 'your_secret_key', { expiresIn: '1h' });
            res.json({ success: true, token });
        } else {
            res.json({ success: false, message: 'Correo electrónico o contraseña incorrectos' });
        }
    });
});

// Añadir esta función para obtener la imagen asociada a un correo electrónico
app.post('/proyecto_flutter/getImageByEmail', (req, res) => {
    const email = req.body.email;

    const query = 'SELECT imagen FROM users WHERE email = ?';
    db.query(query, [email], (err, results) => {
        if (err) throw err;

        if (results.length === 0) {
            return res.status(404).json({ success: false, message: 'No se encontró el correo electrónico' });
        }

        const image = results[0].imagen;
        res.setHeader('Content-Type', 'image/jpeg');
        res.send(image);
    });
});

//incrementar el número de entradas que ha hecho el usuario a su cuenta
app.post('/proyecto_flutter/incrementEntradas', (req, res) => {
    const email = req.body.email;

    if (!email) {
        return res.status(400).json({ success: false, message: 'Se requiere el parámetro email' });
    }

    const queryGet = 'SELECT entradas FROM users WHERE email = ?';
    db.query(queryGet, [email], (err, results) => {
        if (err) throw err;

        if (results.length === 0) {
            return res.status(404).json({ success: false, message: 'No se encontró el usuario' });
        }

        const entradas = results[0].entradas + 1;

        const queryUpdate = 'UPDATE users SET entradas = ? WHERE email = ?';
        db.query(queryUpdate, [entradas, email], (err, _) => {
            if (err) throw err;

            res.json({ success: true, message: 'Entradas incrementadas en 1', entradas });
        });
    });
});

//devuelve el campo descripcion del usuario al que hemos facilitado el email
app.post('/proyecto_flutter/getDescripcion', (req, res) => {
  const email = req.body.email;

  const query = 'SELECT descripcion FROM users WHERE email = ?';
  db.query(query, [email], (err, results) => {
    if (err) throw err;

    if (results.length === 0) {
      return res.status(404).json({ success: false, message: 'No se encontró el correo electrónico' });
    }

    const descripcion = results[0].descripcion;
    res.json({ success: true, descripcion: descripcion });
  });
});

//modifica el campo descripción del usuario con el email facilitado
app.post('/proyecto_flutter/updateDescripcion', (req, res) => {
    const email = req.body.email;
    const descripcion = req.body.descripcion;

    if (!email || !descripcion) {
        return res.status(400).json({ success: false, message: 'Se requieren los parámetros email y descripcion' });
    }

    const queryUpdate = 'UPDATE users SET descripcion = ? WHERE email = ?';
    db.query(queryUpdate, [descripcion, email], (err, _) => {
        if (err) throw err;

        res.json({ success: true, message: 'Descripción actualizada', descripcion });
    });
});

app.listen(PORT, () => console.log(`Servidor corriendo en el puerto ${PORT}`));

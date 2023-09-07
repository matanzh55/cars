from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime

app = Flask(__name__)

# Configure your PostgreSQL database connection
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://matanzh:Dr69740968$$@20.71.177.25/flask_app'
db = SQLAlchemy(app)

# Define a model for your data
class Data(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(255), nullable=False)
    value = db.Column(db.Float, nullable=False)
    time = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)

@app.route('/data', methods=['GET', 'POST'])
def create_data():
    data_json = request.get_json()

    if 'name' in data_json and 'value' in data_json and 'time' in data_json:
        name = data_json['name']
        value = data_json['value']
        time = datetime.strptime(data_json['time'], "%a %b %d %H:%M:%S %Z %Y")

        new_data = Data(name=name, value=value, time=time)

        db.session.add(new_data)
        db.session.commit()

        return jsonify({'message': 'Data created successfully'}), 201
    else:
        return jsonify({'error': 'Invalid data format'}), 400

if __name__ == '__main__':
    app.run(debug=True,host="0.0.0.0",port=8080)
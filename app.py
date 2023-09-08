from flask import Flask, request, render_template
import psycopg2

app = Flask(__name__)

# Database connection configuration
db_config = {
    'dbname': 'cars',
    'user': 'matanzh',
    'password': 'matanzh',
    'host': '10.0.2.5',  #private IP PostgreSQL VM
    'port': '5432',
}

def connect_to_database():
    try:
        connection = psycopg2.connect(**db_config)
        return connection
    except Exception as e:
        print("Error connecting to the database:", str(e))
        return None

@app.route('/')
def home():
    return render_template('index.html')

@app.route('/cars', methods=['GET'])
def get_cars():
    connection = connect_to_database()
    if connection:
        cursor = connection.cursor()
        cursor.execute("SELECT * FROM books;")
        cars = cursor.fetchall()
        connection.close()
        return render_template('cars.html', cars=cars)
    else:
        return "Database connection error"

@app.route('/add_car', methods=['POST'])
def add_car():
    brand = request.form.get('brand')
    car_number = request.form.get('car_number')
    manufacturing_date = request.form.get("manufacturing_date")

    connection = connect_to_database()
    if connection:
        cursor = connection.cursor()
        cursor.execute("INSERT INTO cars (brand, car_number, manufacturing_date) VALUES (%s, %s, %s);", (brand, car_number, manufacturing_date))
        connection.commit()
        connection.close()
        return "Car added successfully"
    else:
        return "Database connection error"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

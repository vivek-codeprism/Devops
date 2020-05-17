from flask import Flask
from flask_restful import Api, Resource
from requests import put, get

app = Flask(__name__)
api = Api(app)

class Root(Resource):
    def get(self):
        return {'data': 'welcome'}

class Health(Resource):
    def get(self):
        return query('_cluster/health')

def query(route):
    return get('http://localhost:9200/{}'.format(route), auth=('elastic', 'changeme')).json()

api.add_resource(Root, '/')
api.add_resource(Health, '/health')

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)

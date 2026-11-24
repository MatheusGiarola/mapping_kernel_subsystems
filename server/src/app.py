from flask import Flask, render_template

from repository_data import RepositoryData

app = Flask(__name__)

DEFAULT_CSV_PATH = "/data/linux_subsystems.csv"
DATA_DIR_PATH = "/data/"

@app.route('/')
def get_index():
    repo_data = RepositoryData()
    repo_data.load_from(DEFAULT_CSV_PATH)
    data = repo_data.produce_treemap_data(metric="files")
    return render_template('treemap.html', treemap_data = data, maxdepth=2)

@app.route('/loc')
def get_index_loc():
    repo_data = RepositoryData()
    repo_data.load_from(DEFAULT_CSV_PATH)
    data = repo_data.produce_treemap_data(metric="LOC")
    return render_template('treemap.html', treemap_data = data, maxdepth=2)

@app.route('/any/<project>')
def get_any_project_treemap(project):
    repo_data = RepositoryData()
    project_data_path = DATA_DIR_PATH + project + ".csv"
    repo_data.load_from(project_data_path,separator="·")
    return render_template('treemap.html', treemap_data = repo_data.produce_treemap_data(), maxdepth=-1)
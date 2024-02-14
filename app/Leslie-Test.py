import numpy as np
import pandas as pd
import requests
import json
import dash
from dash import dcc, html
from dash.dependencies import Input, Output
import plotly.express as px
import os




url = 'https://www.fema.gov/api/open/v1/MissionAssignments'

#resp = requests.get(url)
#raw = resp.json()
#print(raw.keys())
#dat = raw['MissionAssignments']

script_directory = os.path.dirname(os.path.realpath(__file__))
parent_directory = os.path.dirname(script_directory)
file_path = os.path.join(parent_directory, 'data', 'MissionAssignments.csv')

dat = pd.read_csv(file_path)
dat.head()

column_names = dat.columns.tolist()
print(column_names)


dat['dateObligated'] = pd.to_datetime(dat['dateObligated'])

dat['year_month_obligated'] = dat['dateObligated'].dt.strftime('%Y-%m')





app = dash.Dash(__name__)

app.layout = html.Div([
    html.H1("Entries by Month"),
    dcc.Input(id='selected_year', type='number', min=1900, max=2030, value=2022),
    html.Div(id='histogram')
])


@app.callback(
    Output('histogram', 'children'),
    [Input('selected_year', 'value')]
)
def update_histogram(selected_year):
    filtered_df = dat[pd.to_datetime(dat['dateObligated']).dt.year == selected_year]
    if filtered_df.empty:
        return "No entries for this year"
    else:
        fig = px.histogram(filtered_df, x=pd.to_datetime(filtered_df['dateObligated']).dt.month,
                           labels={'x': 'Month', 'y': 'Number of Entries'},
                           title=f'Entries by Month in {selected_year}')
        return dcc.Graph(figure=fig)


if __name__ == '__main__':
    app.run_server(debug=True, port = 8888)
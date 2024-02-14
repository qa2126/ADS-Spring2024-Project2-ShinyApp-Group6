import numpy as np
import pandas as pd
import requests
import json
import dash
from dash import dcc, html
from dash.dependencies import Input, Output

url = 'https://www.fema.gov/api/open/v1/MissionAssignments'

resp = requests.get(url)

raw = resp.json()
#print(raw.keys())

dat = raw['MissionAssignments']

len(dat)

# Create a Dash application
app_test = dash.Dash(__name__)

# Define the layout of the app
app_test.layout = html.Div([
    dcc.Slider(
        id='input',
        min=1900,
        max=2030,
        step=1,
        value=2020,
        marks={str(year): str(year) for year in range(1900, 2031, 10)}
    ),
    html.Div(id='output')
])

# Define callback to update the output whenever the input changes
@app_test.callback(
    Output(component_id='output', component_property='children'),
    [Input(component_id='input', component_property='value')]
)
def update_output_div(input_value):
    return f'You entered: {input_value}'

# Run the app
if __name__ == '__main__':
    app_test.run_server(debug=True, port = 8888)



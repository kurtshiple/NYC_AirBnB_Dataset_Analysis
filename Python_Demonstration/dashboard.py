import dash
from dash import html
from dash import dcc  # Add this line
from dash.dependencies import Input, Output
import folium
from folium.plugins import MarkerCluster
import plotly.express as px
import pandas as pd
import os

# Load the dataset
data = pd.read_csv('../data/NYC_air_bnb_dataset.csv')

app = dash.Dash(__name__)

# Create a Folium map
ny_map = folium.Map(location=[40.7128, -73.9060], zoom_start=11)
marker_cluster = MarkerCluster().add_to(ny_map)

# Add markers for each listing
for index, row in data.iterrows():
    folium.Marker(
        location=[row['latitude'], row['longitude']],
        popup=f"<b>Name</b>: {row['name']}, <b>Price</b>: ${row['price']}, <b>Type</b>: {row['room_type']}",
    ).add_to(marker_cluster)

# Create a Plotly scatter plot
scatter_fig = px.scatter(data, x='latitude', y='longitude', color='room_type', title='Room Types')
scatter_fig.update_traces(marker=dict(size=5))

# Create a Plotly bar chart
bar_fig = px.bar(data, x='room_type', y='price',color='room_type', title='Price by Room Type')


# Get a list of image filenames in the folder
image_files = [f for f in os.listdir('assets') if f.endswith('.png')]




app.layout = html.Div([

    html.H1("Dash App Dashboard w/ EDA Charts", style={'text-align': 'center'}),  # Header
    html.H2("Map", style={'text-align': 'center'}),  # Header
    html.Iframe(srcDoc=ny_map._repr_html_(), width='100%', height='600'),
    html.H2("Room Types", style={'text-align': 'center'}),  # Header
    dcc.Graph(figure=scatter_fig),
    html.H2("Price By Room Type", style={'text-align': 'center'}),  # Header
    dcc.Graph(figure=bar_fig),
    html.H2("Image Gallery", style={'text-align': 'center'}),
    *[html.Div([
        html.H2(image.split('.')[0], style={'text-align': 'center'}),  # Use the image name as the header
        html.Img(src=app.get_asset_url(f'{image}'),style={'display': 'block', 'margin': '0 auto'}, width='80%')
    ]) for image in image_files]
])

if __name__ == '__main__':
    app.run_server(debug=True)



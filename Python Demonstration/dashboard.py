import dash
from dash import html
from dash import dcc  # Add this line
from dash.dependencies import Input, Output
import folium
from folium.plugins import MarkerCluster
import plotly.express as px
import pandas as pd

# Load the dataset
data = pd.read_csv('data/NYC_air_bnb_dataset.csv')

app = dash.Dash(__name__)

# Create a Folium map
ny_map = folium.Map(location=[40.7128, -73.6060], zoom_start=12)
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




app.layout = html.Div([
    html.Iframe(srcDoc=ny_map._repr_html_(), width='100%', height='600'),
    dcc.Graph(figure=scatter_fig),
    dcc.Graph(figure=bar_fig),
])

if __name__ == '__main__':
    app.run_server(debug=True)



import plotly.express as px
from shiny.express import input, render,output
from shiny.express import ui as expui
from shiny import ui
from shiny.types import ImgData
import seaborn as sns
import pandas as pd
import ipyleaflet as L
from shinywidgets import output_widget, register_widget, reactive_read,render_widget

expui.page_opts(title="Citibike And WeatherNYC", fillable=True)

with expui.nav_panel("Intro"):

    # with expui.card():

    ui.layout_columns(
        ui.card(  
            ui.card_header("Impact of Weather Conditions on Bike Usage"),
            ui.p("a. Analyze the usage of Citibike under different weather conditions, such as temperature, rainfall, wind speed, etc."),
            ui.p("b. Examine the changes in bike usage during specific weather events, such as heavy rain or heatwaves."),
        ) ,
        ui.card(  
            ui.card_header("Time Dimension Analysis"),
            ui.p("a. Study the patterns of bike usage at different times of the day (like morning or evening peak hours) or on different days of the week (weekdays vs weekends)."),
            ui.p("b. Analyze the impact of seasonal changes on bike usage patterns, exploring if there are noticeable seasonal trends."),
            
        ),
         ui.card(  
            ui.card_header("Spatial Dimension Analysis"),
            ui.p("a. Identify areas with the highest and lowest usage of bicycles and explore whether these patterns are influenced by weather conditions."),
            ui.p("b. Analyze whether people are more inclined to use bicycles in certain areas under specific weather conditions.")
        )
    )
        # ui.h1("Introduction"),
        # ui.h3("Impact of Weather Conditions on Bike Usage")

        # ui.h3("Time Dimension Analysis:")
        # ui.h3("Spatial Dimension Analysis")
        # 
        # 
    
    @render.image
    def image():
        from pathlib import Path
        dir = Path(__file__).resolve().parent
        img: ImgData = {"src": str(dir / "/Users/chenjianfeng/Desktop/citybike-demo-app/bike_sharing.jpg"), "width": "100%"}
        return img

with expui.nav_panel("Table"):
    @render.data_frame
    def table():
        return citybike_df.head()
with expui.nav_panel("Static Plots"): 
    citybike_df = pd.read_csv("/Users/chenjianfeng/Desktop/citybike-demo-app/citibike_data.csv")
    citybike_df['usage'] = abs(citybike_df['startcount'] - citybike_df['endcount'])
    usage_series = citybike_df.groupby(['date'])['usage'].sum()


    dately_analysis_df = usage_series.to_frame()
    dately_analysis_df['date'] = dately_analysis_df.index
    dately_analysis_df.index = pd.to_datetime(dately_analysis_df.index)
    weekly_analysis_df = dately_analysis_df.resample('W').sum()

    weekly_analysis_df['date'] = weekly_analysis_df.index
    weekly_analysis_df['date_str'] = weekly_analysis_df['date'].dt.strftime('%Y-%m-%d')

    @output
    @render.plot
    def barplot():
        barplot  = sns.barplot(x=usage_series.index,y=usage_series.values) 
        barplot.set_xticklabels(barplot.get_xticklabels(), rotation=90)
        return barplot
    
    @output
    @render.plot
    def barplot2():
        barplot  = sns.barplot(x=weekly_analysis_df.date_str,y=weekly_analysis_df.usage) 
        barplot.set_xticklabels(barplot.get_xticklabels(), rotation=90)
        return barplot
    
with expui.nav_panel("Map"): 

    @render_widget
    def map():
        return L.Map(zoom=2)
    
    @render.text
    def center():
        cntr = reactive_read(map.widget, 'center')
        return f"Current center: {cntr}"
   
    # # When the slider changes, update the map's zoom attribute (2)
    # @reactive.Effect
    # def _():
    #     map.zoom = input.zoom()

    # # When zooming directly on the map, update the slider's value (2 and 3)
    # @reactive.Effect
    # def _():
    #     ui.update_slider("zoom", value=reactive_read(map, "zoom"))

    # # Everytime the map's bounds change, update the output message (3)
    # @output
    # @render.text
    # def map_bounds():
    #     b = reactive_read(map, "bounds")
    #     lat = [b[0][0], b[0][1]]
    #     lon = [b[1][0], b[1][1]]
    #     return f"The current latitude is {lat} and longitude is {lon}"

# with ui.nav_panel("static plot"):
#     @render.data_frame
#     def table():
#         return px.data.tips()
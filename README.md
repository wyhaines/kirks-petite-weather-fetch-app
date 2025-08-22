# Kirk's Weather App

![screenshot](screenshot.png)

This is a weather forcast fetching application built with Ruby on Rails 8. It has real-time weather data, 5-day forecasts, and caching of forecast results.
The application uses Hotwire for dynamic interactions and Tailwind CSS for a sleek dark-themed interface.
The only database dependency is SQLite, so this can readily be ran anywhere.

It leverages OpenWeatherMap for the forecasts. Their free tier for API access allow 1000 API queries per day, which is ample for an example app like this.

Notes: I cribbed a bunch of the styling from a couple other projects that I have going on, to get something sleek and attractive quickly.

## Requirements

- Ruby 3.0+
- Rails 8.0+
- SQLite3
- Node.js (for Tailwind CSS compilation)

## Setup Instructions

### 1. Clone the Repository

```bash
git clone <repository-url>
cd kirks_weather_app
```

### 2. Install Dependencies

```bash
bundle install
```

### 3. Get OpenWeatherMap API Key

This is crucial. It won't work without an API key. You can get one from OpenWeatherMap easily, however:

1. Visit [OpenWeatherMap](https://openweathermap.org/api)
2. Sign up for a free account
3. Generate an API key from your account dashboard

### 4. Configure Environment Variables

Tl;Dr You don't need to. This repo has a .env with a free tier OpenWeatherMap API key. If you have your
own that you want to use, edit the add your OpenWeatherMap API key:

```
OPENWEATHER_API_KEY=your_actual_api_key_here
```

But so long as this hasn't received heavy use on any given day, the included free tier key should work fine.

### 5. Start the Application

Assuming the bundle install worked without a problem, you should be able to just start the application as follows and it'll work on your system:

```bash
bin/dev
```

The application defaults to running on `http://localhost:3000`.


## Architecture

It's basically the simplest thing that both works and looks good doing it.

### Services

- **`OpenweatherApi`**: Handles direct API communication with OpenWeatherMap
- **`WeatherService`**: Orchestrates weather data fetching, caching, and formatting

### Frontend

- **Hotwire**: This is the way. I actually like React, but most of the time Hotwire does everything that I could want.
- **Tailwind CSS**: I adore Tailwind. I tend to use it on most of my projects.
- **Responsive Design**: Always good to try to make things mobile-friendly right from the beginning.

## License

This project is available as open source under the terms of the MIT License.

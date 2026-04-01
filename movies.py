import requests
import json

API_KEY = "89373b9df0d8efc47245fc4c20c92713"

url = f"https://api.themoviedb.org/3/movie/popular?api_key={API_KEY}"

response = requests.get(url)
data = response.json()

movies = []

for movie in data["results"]:
    movies.append({
        "title": movie["title"],
        "rating": movie["vote_average"],
        "release_date": movie["release_date"]
    })

with open("movies.json", "w") as f:
    json.dump(movies, f, indent=4)

print("Done! Movie data saved 🎬")
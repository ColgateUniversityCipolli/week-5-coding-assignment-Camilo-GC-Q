# Step 0
# install.packages("stringr")
library(stringr)
# install.packages("jsonlite")
library(jsonlite)
# install.packages("tidyverse")
library(tidyverse)

# help(separate)
# help(str_sub)
# help(str_split)
# help(str_remove)
# help(tibble)
# help(list.files)
# Step 1

current.filename = tibble(file.name = "EssentiaOutput/The Front Bottoms-Talon Of The Hawk-Au Revoir (Adios).json")

file = current.filename %>%
  separate(file.name, into = c("path", "artist_album_track"), sep = "/", extra = "merge") %>%
  separate(artist_album_track, into = c("artist", "album", "track"), sep = "-", extra = "merge") %>%
  mutate(track = str_sub(track, 1, nchar(track) - 5)) %>%
  select(artist, album, track)

print(file)

file.data = fromJSON(current.filename$file.name[1])
data = tibble(
  overall_loudness = file.data$lowlevel$loudness_ebu128$integrated,
  spectral_energy = file.data$lowlevel$spectral_energy,
  dissonance = file.data$lowlevel$dissonance,
  pitch_salience = file.data$lowlevel$pitch_salience,
  bpm = file.data$rhythm$bpm,
  beats_loudness = file.data$rhythm$beats_loudness,
  danceability = file.data$rhythm$danceability,
  tuning_frequency = file.data$tonal$tuning_frequency
)
View(data)

# Step 2

json.files = list.files("EssentiaOutput", pattern = ".json", full.names = TRUE)
frame2 = tibble()

for (song in json.files){
  remove.slash = str_split(song, "/", simplify = TRUE)
  filename = remove.slash[length(remove.slash)]
  
  remove = str_split(filename, "-", simplify = TRUE)
  
  artist = str_split(remove[length(remove) - 2], "/", simplify = TRUE)
  artist = as.character(artist[length(artist)])
  album = as.character(remove[length(remove) - 1])
  album = as.character(album[length(album)])
  track = str_sub(remove[length(remove)], 1, nchar(remove[length(remove)]) - 5)
  
  file.data2 = fromJSON(song)
  row = tibble(
    artist = artist,
    album = album,
    track = track,
    overall_loudness = file.data2$lowlevel$loudness_ebu128$integrated,
    spectral_energy = file.data2$lowlevel$spectral_energy$mean,
    dissonance = file.data2$lowlevel$dissonance$mean,
    pitch_salience = file.data2$lowlevel$pitch_salience$mean,
    bpm = file.data2$rhythm$bpm,
    beats_loudness = file.data2$rhythm$beats_loudness$mean,
    danceability = file.data2$rhythm$danceability,
    tuning_frequency = file.data2$tonal$tuning_frequency
  )
  frame2 = bind_rows(frame2, row)
  dframe2 = as.data.frame(frame2)
}

View(dframe2)

# Step 3

csv = read.csv("EssentiaOutput/EssentiaModelOutput.csv") %>%
  mutate(
    v_sum = (deam_valence + emo_valence + muse_valence) / 3,
    a_sum = (deam_arousal + emo_arousal + muse_arousal) / 3,
    
    aggressive = (eff_aggressive + nn_aggressive) / 2,
    happy = (eff_happy + nn_happy) / 2,
    party = (eff_party + nn_party) / 2,
    relaxed = (eff_relax + nn_relax) / 2,
    sad = (eff_sad + nn_sad) / 2,
    
    acoustic = (eff_acoustic + nn_acoustic) / 2,
    electric = (eff_electronic + nn_electronic) / 2,
    
    instrumental = (eff_instrumental + nn_instrumental) / 2
  ) %>%
  rename(timbreBright = eff_timbre_bright) %>%
  select(artist, album, track, timbreBright, v_sum, 
         a_sum, aggressive, happy, party, relaxed, 
         sad, acoustic, electric, instrumental)


# Step 4

liw = read.csv("LIWCOutput/LIWCOutput.csv")
merge.data = csv %>%
  left_join(liw, by = c("artist", "album", "track")) %>%
  left_join(frame2, by = c("artist", "album", "track")) %>%
  rename("funct" = "function.")

trainingdata = merge.data %>% filter(track != "Allentown")
write_csv(trainingdata, "trainingdata.csv")

testingdata = merge.data %>% filter(track == "Allentown")
write_csv(trainingdata, "testingdata.csv")
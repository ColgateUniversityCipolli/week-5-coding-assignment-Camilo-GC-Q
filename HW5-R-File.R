# Step 0
# install.packages("stringr")
library(stringr)
# install.packages("jsonlite")
library(jsonlite)
# install.packages("tidyverse")
library(tidyverse)

help(separate)
help(str_sub)
help(str_split)
help(str_remove)
help(tibble)
help(list.files)
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
print(data)

# Step 2

json.files = list.files("EssentiaOutput", pattern = ".json", full.names = TRUE)
frame2 = tibble()

for (song in json.files){
  remove.slash = str_split(song, "/")
  filename = remove.slash[length(remove.slash)]
  
  remove = str_split(filename, "-")
  artist = str_split(remove[length(remove) -2], "/")
  album = remove[length(remove) - 1]
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
}


# Step 3

# 1
# csv = read.csv("EssentiaOutput/EssentiaModelOutput.csv")
# 
# # 2
# v_fir = csv$deam_valence
# v_sec = csv$emo_valence
# v_thir = csv$muse_valence
# (v_sum = (v_fir + v_sec + v_thir)/3)
# 
# a_fir = csv$deam_arousal
# a_sec = csv$emo_arousal
# a_thir = csv$muse_arousal
# (a_sum = (a_fir + a_sec + a_thir)/3)
# 
# csv$v_sum = v_sum
# csv$a_sum = a_sum
# # View(csv)
# 
# # 3
# aggressive = (csv$eff_aggressive + csv$nn_aggressive) / 2
# happy = (csv$eff_happy + csv$nn_happy) / 2
# party = (csv$eff_party + csv$nn_party) / 2
# relaxed = (csv$eff_relax + csv$nn_relax) / 2
# sad = (csv$eff_sad + csv$nn_sad) / 2
# 
# csv$aggressive = aggressive
# csv$happy = happy
# csv$party = party
# csv$relaxed = relaxed
# csv$sad = sad
# # View(csv)
# 
# # 4
# acoustic = (csv$eff_acoustic + csv$nn_acoustic) / 2
# electric = (csv$eff_electronic + csv$nn_electronic) / 2
# 
# csv$acoustic = acoustic
# csv$electric = electric
# # View(csv)
# 
# # 5
# 
# instrumental = (csv$eff_instrumental + csv$nn_instrumental) / 2
# csv$instrumental = instrumental
# # View(csv)
# 
# # 6
# names(csv)[names(csv) == 'eff_timbre_bright'] = 'timbreBright'
# # View(csv)
# 
# # 7
# csv = subset(csv, select=c('artist', 'album', 'track', 'timbreBright', 'v_sum',
#                            'a_sum', 'aggressive', 'happy', 'party', 'relaxed', 
#                            'sad', 'acoustic', 'electric', 'instrumental'))
# View(csv)

# Step 4

# 1
liw = read.csv("LIWCOutput/LIWCOutput.csv")
View(liw)

# 2
help("merge")
dim(csv)
dim(liw)
dim(frame2)

merged1 = merge(csv, liw, by = c("artist", "album", "track"), all.x = TRUE)
View(merged1)
merged2 = merge(merged1, frame2, by = c("artist", "album", "track"), all.x = TRUE)
View(merged2)

# 3
names(merged2)[names(merged2) == 'function.'] = 'funct'
# colnames(merged2)
# Step 5

# 1
trainingdata = merged2[merged2$"track" != "Allentown", ]
write.csv(trainingdata, "trainingdata.csv")

# 2
testingdata = merged2[merged2$"track" == "Allentown", ]
write.csv(testingdata, "testingdata.csv")
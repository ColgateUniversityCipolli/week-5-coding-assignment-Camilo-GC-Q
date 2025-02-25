# Step 0
# install.packages("stringr")
library(stringr)
# install.packages("jsonlite")
library(jsonlite)
# install.packages("tidyverse")
library(tidyverse)

help(separate)
help(str_sub)
# Step 1

current.filename = "EssentiaOutput/The Front Bottoms-Talon Of The Hawk-Au Revoir (Adios).json"

file = current.filename %>%
  separate(current.filename, into = c("path", "artist_album_track"), sep = "/", extra = "merge") %>%
  separate(artist_album_track, into = c("artist", "album", "track"), sep = "-", extra = "merge") %>%
  mutate(track = str_remove(track, "\\.json$")) %>%
  select(artist, album, track)

print(file)

# for(name in current.filename){
#   remove = str_split(name, "-")
#   # print(remove)
#   artist = remove[[1]][length(remove[[1]])-2]
#   remove.slash = str_split(artist, "/")
#   # print(remove.slash)
#   new.artist = remove.slash[[1]][length(remove.slash[[1]])]
#   # print(new.artist)
#   album = remove[[1]][length(remove[[1]])-1]
#   track = remove[[1]][length(remove[[1]])]
#   track = str_sub(track, 1, length(name) - 7)
#   new.names = data.frame(new.artist, album, track)
#   name = rbind(name, new.names)
#   # print(artist)
#   # print(album)
#   # print(track)

View(name)

file.data = fromJSON(current.filename)
names(file.data)
(overall_loudness = file.data$lowlevel$loudness_ebu128$integrated)
(spectral_energy = file.data$lowlevel$spectral_energy)
(dissonance = file.data$lowlevel$dissonance)
(pitch_salience = file.data$lowlevel$pitch_salience)
(bpm = file.data$rhythm$bpm)
(beats_loudness = file.data$rhythm$beats_loudness)
(danceability = file.data$rhythm$danceability)
(tuning_frequency = file.data$tonal$tuning_frequency)

# Step 2
json.files = c()
frame2 = NULL
file = list.files("EssentiaOutput")
# print(file)
for (songs in file){
  if (str_count(songs, ".json") > 0){
    remove = str_split(songs, "-")
    # print(remove)
    artist1 = remove[[1]][length(remove[[1]])-2]
    remove.slash = str_split(artist1, "/")
    # print(remove.slash)
    artist = remove.slash[[1]][length(remove.slash[[1]])]
    # print(new.artist)
    album = remove[[1]][length(remove[[1]])-1]
    track = remove[[1]][length(remove[[1]])]
    track = str_sub(track, 1, length(name) - 9)
    file.data = fromJSON(paste("EssentiaOutput/", songs, sep = ""))
    # print(file.data)
    # names(file.data)
    overall_loudness = file.data$lowlevel$loudness_ebu128$integrated
    spectral_energy = file.data$lowlevel$spectral_energy$mean
    dissonance = file.data$lowlevel$dissonance$mean
    pitch_salience = file.data$lowlevel$pitch_salience$mean
    bpm = file.data$rhythm$bpm
    beats_loudness = file.data$rhythm$beats_loudness$mean
    danceability = file.data$rhythm$danceability
    tuning_frequency = file.data$tonal$tuning_frequency
    combo = data.frame(artist, album, track, overall_loudness, spectral_energy, dissonance, pitch_salience, bpm, beats_loudness, danceability, tuning_frequency)
    frame2 = rbind(frame2, combo)
  }
}
View(frame2)

# Step 3

# 1
csv = read.csv("EssentiaOutput/EssentiaModelOutput.csv")

# 2
v_fir = csv$deam_valence
v_sec = csv$emo_valence
v_thir = csv$muse_valence
(v_sum = (v_fir + v_sec + v_thir)/3)

a_fir = csv$deam_arousal
a_sec = csv$emo_arousal
a_thir = csv$muse_arousal
(a_sum = (a_fir + a_sec + a_thir)/3)

csv$v_sum = v_sum
csv$a_sum = a_sum
# View(csv)

# 3
aggressive = (csv$eff_aggressive + csv$nn_aggressive) / 2
happy = (csv$eff_happy + csv$nn_happy) / 2
party = (csv$eff_party + csv$nn_party) / 2
relaxed = (csv$eff_relax + csv$nn_relax) / 2
sad = (csv$eff_sad + csv$nn_sad) / 2

csv$aggressive = aggressive
csv$happy = happy
csv$party = party
csv$relaxed = relaxed
csv$sad = sad
# View(csv)

# 4
acoustic = (csv$eff_acoustic + csv$nn_acoustic) / 2
electric = (csv$eff_electronic + csv$nn_electronic) / 2

csv$acoustic = acoustic
csv$electric = electric
# View(csv)

# 5

instrumental = (csv$eff_instrumental + csv$nn_instrumental) / 2
csv$instrumental = instrumental
# View(csv)

# 6
names(csv)[names(csv) == 'eff_timbre_bright'] = 'timbreBright'
# View(csv)

# 7
csv = subset(csv, select=c('artist', 'album', 'track', 'timbreBright', 'v_sum',
                           'a_sum', 'aggressive', 'happy', 'party', 'relaxed', 
                           'sad', 'acoustic', 'electric', 'instrumental'))
View(csv)

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
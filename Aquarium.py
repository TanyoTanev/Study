
height = int(input()) # in cm
width = int(input()) # in cm
length = int(input()) # in cm

volume_taken_perc = float(input())

volume = height * width * length *0.001 # in litres

volume_taken = volume * (1- volume_taken_perc/100)



print (f" количеството литри са { volume - volume_taken : .3f} ")
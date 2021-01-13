# ancestors-location-animation
This is a Processing (processing.org) sketch that creates an animated data visualization of how my ancestors migrated over time on a map. It uses a CSV that I exported from MyHeritage and it makes use of the library Unfolding Maps by Till Nagel.

You can watch a video of the animation here:
https://youtu.be/tT4xw3nO1Yg

For more details about the process have a look here:
https://ybrouwer.medium.com/visualizing-my-ancestry-on-a-map-7af6a2354db0

# Getting started
1. Download Processing 3 from https://processing.org/ and install it
2. Download my code
3. Find Unfolding.zip, it's the mapping library I used. Make sure you use the version I supplied, it's the beta which works with Processing 3. Others will not work.
4. Place the unzipped folder 'Unfolding' in the 'libraries' folder of Processing. You can find the folder by opening Processing and going to File->Preferences.
Open the path you find under 'Sketchbook location' in Windows Explorer or Finder and browse to the folder libraries within that folder. Paste the Unfolding folder there.
5. Restart Processing and open my sketch ancestor_map_animation_final.pde
6. Click on the play icon to run the cod. You should see the basemap with dots on it moving randomly.
7. It's time to enter your own data, have a look at the Medium article above and the file ancestors_randomized.csv in the data folder to see how it should be structured. 
8. You can edit the data for example in Google Sheets or Microsoft Excel. Save it as ancestors_randomized.csv in the data folder to see how it runs with my code.
9. Check the comments in my code to see how you can change the keyframes of the animation.
10. If you're happy with your animation it's time to export your movie. Change the line 'boolean recording = false;' to 'boolean recording = true;' and run the code in presentation mode (Sketch->Present). 
11. The animation will run very slowly (can take minutes or even hours to finish) and save every frame as a png within the folder from which you ran the code.
12. If this process is finished, you can use the Movie Maker tool in Processing (Tools-Movie Maker) or video editting software like Adobe Premiere Pro to stitch the images into a movie.
13. I would love to see your end results! Send me a message (https://yannickbrouwer.nl/about/)

Cheers!

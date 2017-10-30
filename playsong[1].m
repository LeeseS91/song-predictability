function playsong(song)
ptime=0.15; 
[sound playrate] = wavread('click.wav');
click = audioplayer(sound, playrate);
% play song
for i=1:length(song);
    if song(i)==1
        play(click)
        pause(ptime)
    else
        pause(ptime);
    end
end

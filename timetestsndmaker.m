%{
timetestsndmaker.m

This function creates audio files with beeps at critical times for use in
DIN based timing tests. It requires an input .csv file with an initial
column containing the output filenames for the .wav files to be created,
and subsequent columns with the times (in ms) at which each beep should be
inserted (i.e., column 2 is a vector of times for which beep 1 occurs in
the output .wav files).

If you need to create files with differing numbers of beep files (e.g.,
sounds 1 - 10 have three beeps, sounds 11 - 20 have four), pad any short
rows by repeating the last requested onset (so in the above example, for
sounds 1 - 10 have the third onset time repeated in the fourth onset time
column).

Created: 2016-04-22 ABF
Last edited: 2016-04-22 ABF

Dependencies: None? Need to check if this uses toolboxes
%}

function [] = timetestsndmaker(onsets)
if nargin < 1
    [datafn, datapath] = uigetfile('*.csv', 'Which file contains beep onset times?');
end

datafid = fopen([datapath datafn]);
onsetdata = textscan(datafid,'%s');
onsetdata = onsetdata{1,1};
onsetdata = cellfun(@(x) strsplit(x, ','), onsetdata, 'UniformOutput', 0);
outnames = cell(size(onsetdata,1),1);
for row = 1:size(onsetdata, 1)
    outnames{row} = onsetdata{row,1}{1};
end

onsets = zeros(size(onsetdata,1), size(onsetdata{1,1},2)-1);
for row = 1:size(onsetdata,1)
    onsets(row,:) = cellfun(@(x) str2num(x), onsetdata{row,1}(2:end));
end

%Beep creation
dur = 0.050; %duration in sec
pitch = 1000; %beep frequency in hz
amp = 0.8; %amplitude in arbitrary units
fs = 44100; %sampling rate of output wave files
ts = 0:1/fs:dur; %vector of samples to generate for token

bp = amp*sin(2*pi*pitch*ts);

% %Ramping code is currently incomplete and nonfunctional - ABF 04/21/2016
% if strcmp(useramps, 'Yes')
%     rampdur = 0.005; %Ramp duration in sec
%     onrampfunc = (amp/rampdur)*x; %m = slope of line from 0 to amp, x = ts from 0 to rampdur, b = 0
% end

%Maybe add in logic to account for ragged arrays (i.e. different number of
%tokens requested for different out files)? My idea was to have trailing NaNs
%replaced with the last requested onset time. - ABF 04/21/2016

%Stimulus creation
for file = 1:size(onsets,1)
    out = 0*(0:1/fs:onsets(file,size(onsets,2))+2*dur); %Create zeros vector as long as the final requested onset plus 2 times the length of the token (to account for token and pad the offset with silence)
    for snd = 1:size(onsets,2)
        sndstart = round((onsets(file,snd)/1000)*fs); %assumes requested onsets are in ms, sets start sample as nearest to requested ms
        out(sndstart:(sndstart+(dur*fs))) = bp;
    end
    disp(['Writing beep sound file ' outnames{file} '...']);
    audiowrite(outnames{file}, out, fs);
end
end
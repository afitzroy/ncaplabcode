function [] = onsetviewer()
[wavfn, expfolder] = uigetfile('*.wav', 'Pick which audio file to plot onsets over');
cd(expfolder);
[onsetfn, onsetfolder] = uigetfile([expfolder '*.csv'], 'Pick .csv file containing autodetected onsets');

[vox, fs] = audioread([expfolder wavfn]);

onset_ms = csvread([onsetfolder onsetfn]);
onset_samp = (onset_ms / 1000) .* fs;

viewintsec = 5;
viewint = viewintsec * fs;
ylims = max(vox)*1.00;
ylims = [-ylims ylims];

for slice = 1:ceil(length(vox)/viewint)
    viewstart = ((slice-1)*viewint);
    viewreg = (viewstart+1):(viewstart+viewint);
    plot(vox(viewreg,1));
    ylim(ylims);
    xlim([0 viewint]);
    set(gca, 'XTick', 0:fs:length(viewreg));
    set(gca, 'XTickLabel', (viewreg(1:fs:length(viewreg))./fs));
    ylabel('Amplitude');
    xlabel('Sound file position (sec)');
    title('Close figure to move to next 5 sec, ctrl-c to quit');
    todraw = onset_samp(onset_samp >= viewstart);
    todraw = todraw(todraw <= viewreg(end));
    if ~isempty(todraw)
        for curline = 1:length(todraw)
            hold on;
            onsetpos = todraw(curline) - viewstart;
            plot([onsetpos onsetpos], ylims, 'k');
            text(onsetpos+(0.05*fs),0.8*ylims(2),num2str((todraw(curline)/fs)*1000));
        end
    end
    curvox = vox(viewreg,1);
    uicontrol('Style', 'pushbutton', 'String', 'Play audio',...
        'Position', [0 0 100 50], 'Callback', {@playcurvox,curvox,fs});
    figsize = get(0,'Screensize');
    figsize(2) = floor(0.1*figsize(4));
    figsize(4) = floor(0.8*figsize(4));
    set(gcf, 'Position', figsize);
    uiwait;
end
end

function [] = playcurvox(obj, event, curvox, fs)
soundsc(curvox, fs);
end
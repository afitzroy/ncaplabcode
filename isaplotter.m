function [ output_args ] = isaplotter( input_args )
%Function for loading several ISA .erps and collating the output into a pdf
%of images.

%NOTE: Currently this is hardcoded to plot bins that are specific to
%LiveNoise ISAs. This should be made more general in the future. - ABF
%2016-08-16

%%%Constants
quote = '''';
expname = 'LiveNoise';
expprefix = 'LN';
if ispc
    expfolder = ['//Glacier/GL_Storage/GL_Experiments/' expname '/'];
elseif ismac
    expfolder = ['/Volumes/GL_Storage/GL_Experiments/' expname '/'];
end

cd(expfolder);

pidlist = dir([expfolder 'Processed_NeuralData']);
pidlist = {pidlist.name};
ispid = cellfun(@(x) ~isempty(x), strfind(pidlist, expprefix), 'UniformOutput', 0);
ispid = cell2mat(ispid);
pidlist = pidlist(ispid);

pidstouse = listdlg('PromptString', ['Which participants to process?'], 'SelectionMode', 'multiple', 'ListString', pidlist);
pidlist = pidlist(pidstouse);


for p = 1:length(pidlist)
       

    PID = pidlist{p};
     
    if PID <= 13;
        erpsuffix = '_AutoOnsets__2016-08-15.erp'; 
        else
        erpsuffix = '_AutoOnsets__2016-08-16.erp';
    end
    
    %Load correct ERP
    ERP = pop_loaderp( 'filename', [PID erpsuffix], 'filepath', [expfolder 'Processed_NeuralData/' PID '/'] );                                                                                                                                                                                                                                                                                                                                                            
    
    %Add channel locations
    ERP = pop_erpchanedit( ERP, '/Volumes/GL_Storage/GL_Lab_Business/labcode/GSN-HydroCel-135_mod_VREF-EOG.sfp');

    %Plot ERP
    ERP = pop_ploterps( ERP,1:2:7,1:129 , 'yscale', [ -5.0 5.0], 'Axsize', [ 0.05 0.08], 'BinNum', 'on', 'Blc', 'no', 'Box', [ 12 11], 'ChLabel', 'on',...
        'FontSizeChan',10, 'FontSizeLeg',12, 'LegPos', 'bottom', 'Linespec', {'b-' , 'r-' , 'c-' , 'm-' },...
        'LineWidth',1, 'Style', 'Topo', 'Tag', 'ERP_figure', 'Position', [1 77 1680 879],...
        'Transparency',0, 'xscale', [ -100.0 598.0 -100:100:500 ], 'YDir', 'reverse', 'AutoYlim', 'off');
    title(PID);

    %Save ERP as ??? (.pdf? .fig? .png? .jpg?)
    %manual for now because speedcoding
    pause;
    
end




end


function iconFile=getIconFile(~)




    if ispc
        iconFile=fullfile(toolboxdir('shared/dsp/webscopes'),'slspectrumanalyzer','resources','spectrumanalyzer','spectrumanalyzer.ico');
    else
        iconFile=fullfile(toolboxdir('shared/dsp/webscopes'),'slspectrumanalyzer','resources','spectrumanalyzer','spectrumanalyzer.png');
    end
end

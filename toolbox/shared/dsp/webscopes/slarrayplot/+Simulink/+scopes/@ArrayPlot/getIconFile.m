function iconFile=getIconFile(~)




    if ispc
        iconFile=fullfile(toolboxdir('shared/dsp/webscopes'),'slarrayplot','resources','arrayplot','arrayplot.ico');
    else
        iconFile=fullfile(toolboxdir('shared/dsp/webscopes'),'slarrayplot','resources','arrayplot','arrayplot.png');
    end
end

function file=getCodeGenCheckFile(studio)



    h=studio.App.blockDiagramHandle;
    isERT=get_param(h,'IsERTTarget');

    if strcmp(isERT,'off')

        file=fullfile(matlabroot,'toolbox','coder',...
        'simulinkcoder_app','code_perspective',...
        'resources','EditTimeCustomization_GRT.json');

    else

        file=fullfile(matlabroot,'toolbox','coder',...
        'simulinkcoder_app','code_perspective',...
        'resources','EditTimeCustomization_ERT.json');

    end



function BrowseButtonCallback(dlgSrc)
    [file,path]=uigetfile('*.slx',DAStudio.message('Simulink:CodeContext:SelectModel'));
    if~isequal(file,0)&&~isequal(path,0)
        dlgSrc.instanceFileName=fullfile(path,file);
        Simulink.libcodegen.dialogs.shared.populateDropdown(dlgSrc);
    end
end

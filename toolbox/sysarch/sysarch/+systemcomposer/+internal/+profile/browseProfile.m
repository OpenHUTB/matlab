function[filePath,file]=browseProfile()




    [file,path]=uigetfile('*.xml',...
    DAStudio.message('SystemArchitecture:ProfileDesigner:ImportProfileTitle'));
    if file==0
        filePath='';
        return
    end
    filePath=fullfile(path,file);
    systemcomposer.internal.profile.ProfileEditorWindows.showStudio;

end

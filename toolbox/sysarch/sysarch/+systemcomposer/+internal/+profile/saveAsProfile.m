function[filePath,file]=saveAsProfile(profileName)



    filePath='';

    [file,path]=uiputfile('*.xml',...
    DAStudio.message('SystemArchitecture:ProfileDesigner:SaveAsTitle'),...
    profileName);
    if file==0
        return;
    else
        filePath=fullfile(path,file);
    end
end


function[names,files]=getRegisteredAttributes(targetName)




    names={};
    files={};
    if codertarget.target.isTargetRegistered(targetName)
        targetFolder=codertarget.target.getTargetFolder(targetName);
        folder=codertarget.target.getAttributeRegistryFolder(targetFolder);
        candidateFiles=codertarget.utils.getFilesInFolder(folder);
        for i=1:numel(candidateFiles)
            name=fullfile(folder,candidateFiles(i).name);
            if locIsAttributesFile(name)
                files{end+1}=candidateFiles(i).name;%#ok<*AGROW>
                h=codertarget.Registry.manageInstance('get','attributes',name);
                names{end+1}=h.getName();
            end
        end
    else
        error(message('codertarget:targetapi:TargetNotRegistered',targetName));
    end
end


function ret=locIsAttributesFile(fileName)
    infoObj=codertarget.Info;
    docObj=infoObj.read(fileName);
    bcItems=docObj.getElementsByTagName('buildconfigurationinfo');
    if~isequal(bcItems.getLength,0)
        ret=false;
    else
        ret=true;
    end
end

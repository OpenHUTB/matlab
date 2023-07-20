function getLibFilesFromDir(obj,dirName)


    if~exist(dirName,'dir')
        return;
    end

    if isfolder(dirName)
        dirData=dir(dirName);

        for i=1:length(dirData)
            try
                if strcmp(dirData(i).name,'.')||strcmp(dirData(i).name,'..')
                    continue;
                end
                if isfolder(dirData(i).name)
                    obj.getLibFilesFromDir(dirData(i).name);
                elseif isfile([dirName,filesep,dirData(i).name])
                    [~,~,ext]=fileparts(dirData(i).name);

                    if strcmp(ext,'.slx')||strcmp(ext,'.mdl')
                        if Simulink.MDLInfo([dirName,filesep,dirData(i).name]).IsLibrary
                            obj.files=[obj.files;{[dirName,filesep,dirData(i).name]}];
                        end
                    end
                end
            catch ME
                errordlg(ME.message);
            end
        end
    else
        [~,~,ext]=fileparts(dirName.name);
        if strcmp(ext,'.slx')||strcmp(ext,'.mdl')
            if Simulink.MDLInfo([dirName,dirName.name]).IsLibrary
                obj.files=[obj.files;{[dirName,dirName.name]}];
            end
        end
    end

end


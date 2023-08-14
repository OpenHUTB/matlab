function nesl_generatedialogschemafile(info)









    gendir=ne_private('ne_gendir');
    [guiDir,guiName]=gendir(info.File);

    maybeDlgFile=fullfile(guiDir,[guiName,'.pmdlg']);
    if exist(maybeDlgFile,'file')
        delete(maybeDlgFile);
    end


    genDir=ne_private('ne_gendir');
    dlgDir=genDir(info.File);
    try
        guiStruct.info.GuiFile=fullfile(...
        fileparts(info.File),'/gui/',[info.Name,'.m']);
        guiInfo=nesl_readguifile(guiStruct);
        if~isempty(guiInfo)
            lWriteOutDlgSchema(maybeDlgFile,dlgDir,guiInfo);
            clear(info.File);
        end
    catch ME



        msgid_mkdir='MATLAB:MKDIR:OSError';
        msgids_save={'MATLAB:save:couldNotWriteFile',...
        'MATLAB:save:permissionDenied'};
        protectedDir='';
        if strcmp(ME.identifier,msgid_mkdir)
            protectedDir=fileparts(info.File);
        elseif any(strcmp(ME.identifier,msgids_save))
            protectedDir=dlgDir;
        end
        if~isempty(protectedDir)
            newException=pm_exception(...
            'physmod:ne_sli:nesl_generatedialogschemafile:CannotWriteFiles',...
            protectedDir);
            newException=newException.addCause(ME);
            newException.throwAsCaller();
        end

        ME.rethrow();
    end

end

function lWriteOutDlgSchema(dlgFile,dlgDir,guiInfo)



    if(~exist(dlgDir,'dir'))
        [status,msgStr,msgId]=mkdir(dlgDir);
        if status~=1
            error(msgId,msgStr);
        end
    end

    save(dlgFile,'guiInfo','-MAT');



    fileattrib(dlgFile,'-w -w -w');

end



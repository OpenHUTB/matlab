function retPath=checkFilePath(testFilePath)
    [pathstr,name,ext]=fileparts(testFilePath);
    if(isempty(name))
        error(message('stm:Parameters:InvalidFileName'));
    end
    if(~strcmp(ext,'.mldatx'))
        ext='.mldatx';
    end
    checkPath=stm.internal.report.createPath(pathstr);
    if(~checkPath)
        error(message('stm:reportOptionDialogText:FailToCreateOutputFile'));
    end

    [~,values]=fileattrib(pathstr);
    if(values.UserWrite==0)
        error(message('stm:CoverageStrings:CovTopOff_Error_FolderIsReadOnly',pathstr));
    end

    idx=1;
    retPath=fullfile(pathstr,[name,ext]);
    while(exist(retPath,'file'))
        tmpName=[name,num2str(idx)];
        retPath=fullfile(pathstr,[tmpName,ext]);
        idx=idx+1;
    end
end
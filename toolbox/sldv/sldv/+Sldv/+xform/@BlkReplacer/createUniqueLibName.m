function[libName,libfullPath]=createUniqueLibName(modelH,testcomp,opts)




    if~isempty(testcomp)
        copymodelFullPath=testcomp.resolvedSettings.BlockReplacementModelFileName;
    else
        copymodelFullPath='';
    end

    MakeOutputFilesUnique='on';
    if isempty(copymodelFullPath)
        FilePathBlockReplacementMdl=get(opts,'BlockReplacementModelFileName');
        FilePathBlockReplacementMdl=[FilePathBlockReplacementMdl,'_lib'];
    else
        [pathstr,name,ext]=fileparts(copymodelFullPath);
        FilePathBlockReplacementMdl=fullfile(pathstr,[name,'_lib',ext]);
    end
    FilePathBlockReplacementMdl=strrep(FilePathBlockReplacementMdl,...
    'replacement','rt');

    fullPath=Sldv.utils.settingsFilename(...
    FilePathBlockReplacementMdl,...
    MakeOutputFilesUnique,...
    '$ModelExt$',modelH,false,true,opts);

    [~,newName]=fileparts(fullPath);
    if length(newName)>63
        count=1;
        [~,tempName]=fileparts(FilePathBlockReplacementMdl);
        while length(newName)>63
            FilePathBlockReplacementModel=tempName(1:end-count);
            fullPath=Sldv.utils.settingsFilename(...
            FilePathBlockReplacementModel,...
            'on',...
            '$ModelExt$',modelH,false,true,opts);
            [~,newName]=fileparts(fullPath);
            count=count+1;
        end
    end

    if isempty(fullPath)
        error(message('Sldv:xform:BlkReplacer:createUniqueLibName:CreateLib'));
    end

    [libPath,libName]=fileparts(fullPath);
    libName=sldvshareprivate('cmd_check_for_open_models',libName,MakeOutputFilesUnique,false);
    if isempty(libName)
        error(message('Sldv:xform:BlkReplacer:createUniqueLibName:CreateLib'));
    end
    libfullPath=fullfile(libPath,[libName,'.slx']);
end


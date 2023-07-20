




function out=getCodeGenFiles(aObj)
    out=[];
    bi=aObj.loadBuildInfoFile();


    fnames=bi.buildInfo.getFullFileList;


    BuildDirInfo=RTW.getBuildDir(aObj.getModelName());
    if aObj.getTopModel
        codeGenDir=BuildDirInfo.BuildDirectory;
    else
        codeGenDir=[BuildDirInfo.CodeGenFolder,filesep,BuildDirInfo.ModelRefRelativeBuildDir];
    end


    fnames=slci.internal.normFileSep(fnames);
    codeGenDir=slci.internal.normFileSep(codeGenDir);
    codeGenFiles=fnames(contains(fnames,codeGenDir));

    subsysFiles=codeGenFiles(contains(codeGenFiles,'.c'));

    subsysHeaderFiles=codeGenFiles(contains(codeGenFiles,'.h'));

    subsysFilesPath=strtok(subsysFiles,'.');
    subsysHeaderFilesPath=strtok(subsysHeaderFiles,'.');

    subsysFiles=subsysFiles(isCodeGenFile(aObj,subsysFilesPath,subsysHeaderFilesPath));


    suffix=aObj.getTargetLangSuffix;
    subsysFiles=setdiff(subsysFiles,{[codeGenDir,filesep,aObj.getModelName(),suffix]});
    for i=1:numel(subsysFiles)

        [~,filename]=fileparts(subsysFiles{i});
        if~isempty(filename)
            out{end+1}=filename;%#ok
        end
    end
end







function out=isCodeGenFile(aObj,cFiles,headerFiles)
    out=false(size(cFiles));
    for i=1:numel(cFiles)
        if any(strcmp(headerFiles,cFiles{i}))

            out(i)=true;
        else
            sharedUtilFolder=aObj.getSharedUtilsFolder();
            [~,filename]=fileparts(cFiles{i});
            SLFcnHeader=[sharedUtilFolder,filesep,filename,'.h'];
            if isfile(SLFcnHeader)
                out(i)=true;
            end
        end
    end
end


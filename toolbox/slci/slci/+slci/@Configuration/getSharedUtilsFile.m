




function out=getSharedUtilsFile(aObj)
    out=[];
    bi=aObj.loadBuildInfoFile();


    fnames=bi.buildInfo.getFullFileList;


    sharedUtilDir=RTW.getBuildDir(aObj.getModelName()).SharedUtilsTgtDir;


    fnames=slci.internal.normFileSep(fnames);
    sharedUtilDir=slci.internal.normFileSep(sharedUtilDir);
    utilsFile=fnames(~cellfun('isempty',strfind(fnames,sharedUtilDir)));

    utilsFile=utilsFile(~cellfun('isempty',strfind(utilsFile,'.c')));
    for i=1:numel(utilsFile)

        [~,filename]=fileparts(utilsFile{i});
        if~isempty(filename)
            out{end+1}=filename;%#ok
        end
    end
end

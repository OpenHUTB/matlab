function filesStruct=findGeneratedSource(report)





    filesStruct=[];


    if~isfield(report.summary,'buildInfo')
        return;
    elseif~report.summary.passed
        if~isfield(report.summary,'buildResults')||isempty(report.summary.buildResults)
            return;
        end
    end

    buildInfo=report.summary.buildInfo;
    buildInfo.updateFilePathsAndExtensions();
    buildDir=emlcprivate('emcGetBuildDirectory',buildInfo,coder.internal.BuildMode.Normal);
    isUncChange=ispc()&&startsWith(report.summary.directory,'\\')&&~startsWith(buildDir,'\\');
    foundAny=false;

    if~isfield(report.summary,'codingTarget')||strcmpi(report.summary.codingTarget,'MEX')
        filesStruct.Source=getFilesByGroup({},{'Interface','Examples','AutoVerify','AutoInterface','TFL'});
    else
        filesStruct.Source=getFilesByGroup({},{'Interface','Examples','AutoVerify','AutoInterface'});
    end
    filesStruct.Examples=getFilesByToken({'EXAMPLE_MAIN_SRC_FILE','EXAMPLE_MAIN_HDR_FILE'});
    filesStruct.Interfaces=getFilesByGroup({'AutoInterface','Interface'},{});
    filesStruct.AutoVerify=getFilesByGroup({'AutoVerify'},{});

    if~foundAny
        filesStruct=[];
    end


    function allFiles=getFilesByGroup(includeGroups,excludeGroups)
        srcFiles=buildInfo.getSourceFiles(true,true,includeGroups,excludeGroups);
        incFiles=buildInfo.getIncludeFiles(true,true,includeGroups,excludeGroups);
        allFiles=postprocessFileList([srcFiles,incFiles]);
    end


    function files=getFilesByToken(tokens)
        if isempty(buildInfo.Tokens)
            files={};
            return
        end
        [~,matchIndices]=intersect({buildInfo.Tokens.Key},tokens,'stable');
        files=postprocessFileList({buildInfo.Tokens(matchIndices).Value});
    end


    function files=postprocessFileList(files)
        if isempty(files)
            files={};
            return
        end

        filesExist=false(size(files));
        for i=1:numel(files)
            filesExist(i)=isfile(files{i});
        end
        files=reshape(sort(files(filesExist)),[],1);

        if isUncChange



            files=replaceBasePath(files,buildDir,report.summary.directory);
        end
        foundAny=foundAny||~isempty(files);
    end
end

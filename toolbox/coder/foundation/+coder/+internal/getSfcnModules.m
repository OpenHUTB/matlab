
function[sfcnModuleFiles,sfcnModuleFilePaths]=getSfcnModules(buildInfo)




    sfcnModulesWithPaths=getSourceFiles(buildInfo,true,true,'Sfcn');

    sfcnMods={};


    mvKeys=get(buildInfo.MakeVars,'Key');
    mvValues=get(buildInfo.MakeVars,'Value');
    sfunIdx=strcmp(mvKeys,'S_FUNCTIONS');
    if any(sfunIdx)
        if iscell(mvValues)
            mvValues=mvValues{sfunIdx};
        end
        sfcnMods=split(mvValues,' ');
    end

    sfcnModulesWithPaths=unique([sfcnModulesWithPaths,sfcnMods'],'stable');

    [sfcnModuleFilePaths,names,exts]=cellfun(@fileparts,sfcnModulesWithPaths,'UniformOutput',false);
    sfcnModuleFiles=strcat(names,exts);

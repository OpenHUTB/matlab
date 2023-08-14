




function cleanUpModels(optArgs,err)



    if nargin==1
        err='';
    end

    absOutDirPath=optArgs.getOptions().AbsOutDirPath;
    newDirCreatedNoLog=optArgs.getOptions().NewDirCreatedNoLog;
    causedByError=optArgs.getEnvironment().CausedByError;
    generateLog=optArgs.getOptions().GenerateLog;





    origModels=optArgs.BDNameRedBDNameMap.keys;
    for mdlIdx=1:numel(origModels)
        currMdlName=origModels{mdlIdx};
        currMdlSLXC=[currMdlName,'.slxc'];
        currMdlSLPRJ=slprivate('getVarCacheFilePath',currMdlName);
        if exist([optArgs.getOptions().AbsOutDirPath,filesep,currMdlSLXC],'file')==2
            try delete(currMdlSLXC);catch,end
        end
        if exist(currMdlSLPRJ,'dir')==7
            try rmdir(currMdlSLPRJ,'s');catch,end
        end
    end

    if generateLog
        optArgs.generateReducerLog(err);
        newDirCreatedNoLog=false;
    end



    errIdForNoOutDirDeletion={'Simulink:Variants:OutputDirPublic',...
    'Simulink:VariantReducer:OutputDirInstall',...
    'Simulink:Variants:ReducerCWDUnderOutputDir',...
    'Simulink:Variants:SameSrcAndDstDirs',...
    'Simulink:Variants:ModelPathUnderOutputDir'};
    if causedByError&&isa(err,'MException')&&...
        ~any(strcmp(err.identifier,errIdForNoOutDirDeletion))


        Simulink.variant.reducer.utils.deleteDirectoryContents(absOutDirPath,true);
    end


    if causedByError&&newDirCreatedNoLog&&isa(err,'MException')&&~any(strcmp(err.identifier,errIdForNoOutDirDeletion(1)))
        rmdir(absOutDirPath,'s');
    end

    warnings=optArgs.Warnings;
    if~isempty(warnings)


        warnMsgs=cellfun(@(x)x.message,warnings,'UniformOutput',false);
        [~,uniIdx]=unique(warnMsgs);
        warnings(setdiff((1:numel(warnings)),uniIdx))=[];
    end
    optArgs.Warnings=warnings;

    if~optArgs.getOptions().VerboseInfoObj.isCalledFromVM()


        for ii=1:numel(warnings)


            warning(warnings{ii}.identifier,'%s',warnings{ii}.message);
        end
    end

end



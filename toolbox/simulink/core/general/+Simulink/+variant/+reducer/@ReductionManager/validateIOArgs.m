








function err=validateIOArgs(rManager)

    err=[];

    modelName=rManager.getOptions().TopModelOrigName;
    outDir=rManager.getOptions().OutputFolder;
    suffix=rManager.getOptions().Suffix;

    try
        [mdlFileName,isLibrary]=i_getModelFileAndLibInfo(rManager.getOptions().TopModelOrigName);
    catch err
        return;
    end


    if isLibrary
        errid='Simulink:Variants:InvalidModelArgLib';
        errmsg=message(errid,1);
        err=MException(errmsg);
        return;
    end

    rManager.getOptions().TopModelFullName=mdlFileName;

    try
        [origMdlPath,~,ext]=fileparts(mdlFileName);
    catch err
        return;
    end

    rManager.getOptions().OrigModelDirPath=origMdlPath;

    redMdlName=[modelName,suffix];
    rManager.getOptions().TopModelName=redMdlName;
    rManager.getOptions().RedModelFullName=[redMdlName,ext];




    if isempty(outDir)
        outDir=[origMdlPath,filesep,'reducedModel'];
        rManager.getOptions().setOutputFolder(outDir);
    end

    if rManager.getOptions().IsConfigVarSpec||~isempty(rManager.getOptions().FullRangeVariables)




        rManager.getOptions().IsConfigSpecifiedAsVariables=true;
    end

    if bdIsLoaded(redMdlName)
        errid='Simulink:Variants:ErrRedMdlIsOpen';
        errmsg=message(errid,redMdlName,get_param(redMdlName,'FileName'));
        err=MException(errmsg);
        return;
    end
end



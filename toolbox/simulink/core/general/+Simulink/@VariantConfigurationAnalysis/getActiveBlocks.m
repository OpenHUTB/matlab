function activeBlocks=getActiveBlocks(obj,configName)










    activeBlocks={};


    parser=inputParser;
    parser.FunctionName='getActiveBlocks';
    parser.StructExpand=false;
    parser.PartialMatching=false;
    checkConfigName=@(x)validateattributes(x,{'char','string'},{'scalartext'});
    addRequired(parser,'ConfigName',checkConfigName);


    try
        parse(parser,configName);
    catch ME
        throwAsCaller(ME);
    end

    configName=convertStringsToChars(configName);


    if~ismember(configName,obj.Configurations)
        errmsg=message('Simulink:VariantManager:ConfigNotAnalyzed',configName);
        err=MException(errmsg);
        throwAsCaller(err);
    end


    try
        obj.cacheData(true);
    catch ME


        throwAsCaller(ME);
    end

    actHandles=obj.mBlkAnalysisInfo.getActiveBlocks(configName);



    activeHs=unique(actHandles);
    activeBlocks=getfullname(activeHs);
    if~iscell(activeBlocks)
        activeBlocks={activeBlocks};
    end
    activeBlocks=arrayfun(@(x)...
    Simulink.variant.utils.replaceNewLinesWithSpaces(x),activeBlocks);

    activeBlocks=activeBlocks(:);

end



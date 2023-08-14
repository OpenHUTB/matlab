function depLibs=getDependentLibraries(obj,configName)











    parser=inputParser;
    parser.FunctionName='getDependentLibraries';
    parser.StructExpand=false;
    parser.PartialMatching=false;
    checkConfigName=@(x)validateattributes(x,{'char','string'},{'scalartext'});
    addRequired(parser,'ConfigName',checkConfigName);


    try
        parse(parser,configName);
    catch ME
        throwAsCaller(ME);
    end


    if~ismember(configName,obj.Configurations)
        errmsg=message('Simulink:VariantManager:ConfigNotAnalyzed',configName);
        err=MException(errmsg);
        throwAsCaller(err);
    end


    obj.cacheData(true);

    depLibs=obj.mBlkAnalysisInfo.getActiveLibs(configName);
    depLibs=depLibs(:);
end



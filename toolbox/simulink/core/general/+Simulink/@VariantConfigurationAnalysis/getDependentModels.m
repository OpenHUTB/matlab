function depModels=getDependentModels(obj,configName)











    parser=inputParser;
    parser.FunctionName='getDependentModels';
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

    depModels=obj.mBlkAnalysisInfo.getActiveModels(configName);
    depModels=depModels(:);
end



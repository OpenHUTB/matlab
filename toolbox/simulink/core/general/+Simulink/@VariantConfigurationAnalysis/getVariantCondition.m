function varCond=getVariantCondition(obj,configName,blockPathOrHandle)












    parser=inputParser;
    parser.FunctionName='getVariantCondition';
    parser.StructExpand=false;
    parser.PartialMatching=false;
    checkConfigName=@(x)validateattributes(x,{'char','string'},{'scalartext'});
    checkBlockPathOrHandle=@(x)validateattributes(x,{'char','string','double'},{'nonempty'});
    addRequired(parser,'ConfigName',checkConfigName);
    addRequired(parser,'BlockPath',checkBlockPathOrHandle);


    try
        parse(parser,configName,blockPathOrHandle);
    catch ME
        throwAsCaller(ME);
    end


    if isnumeric(blockPathOrHandle)
        try
            validateattributes(blockPathOrHandle,{'double'},{'scalar'});
        catch ME
            throwAsCaller(ME);
        end
    else
        try
            validateattributes(blockPathOrHandle,{'char','string'},{'scalartext'});
        catch ME
            throwAsCaller(ME);
        end
    end


    if~ismember(configName,obj.Configurations)
        errmsg=message('Simulink:VariantManager:ConfigNotAnalyzed',configName);
        err=MException(errmsg);
        throwAsCaller(err);
    end


    obj.cacheData(false);

    blockHandle=get_param(blockPathOrHandle,'Handle');
    varCond=obj.mBDMgr.getVariantCondition(blockHandle,configName);

end



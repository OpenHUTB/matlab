function[globalIOs,newGlobalIOChecksum]=getGlobalIOInfo(modelName,gUserSources,feOptions,fullChecksum,settingsChecksum)




    globalIOs=[];
    newGlobalIOChecksum="";

    if~slfeature('CCallerGlobalIO')||isempty(gUserSources)
        return;
    end

    [success,globalIOs,newGlobalIOChecksum]=loadCachedGlobalIOData(settingsChecksum,fullChecksum);
    if success
        return;
    end

    if(~ischar(modelName))
        modelName=get_param(modelName,'Name');
    end

    def.SourceFiles=string(gUserSources);
    def.IncludeDirs=string(feOptions.Preprocessor.IncludeDirs);
    def.Defines=string(feOptions.Preprocessor.Defines);
    args=namedargs2cell(def);

    cCodeInsightObj=polyspace.internal.codeinsight.CodeInsight(args{:});
    success=cCodeInsightObj.parse('DoSimulinkImportCompliance',true);

    if~success
        configSetHyperlink=sprintf('<a href="matlab:SLCC.Utils.OpenConfigureSetAndHightlightGlobalsAsFunctionIO(''%s'')">%s</a>',...
        modelName,configset.internal.getMessage('CustomCodeGlobalsAsFunctionIOName'));
        exception=MException(message('Simulink:CustomCode:GlobalIOParsingError',modelName,configSetHyperlink));
        if(~isempty(cCodeInsightObj.Errors))
            cause=MException('Simulink:CustomCode:GlobalIOParsingErrorCause','%s',cCodeInsightObj.Errors);
            exception=addCause(exception,cause);
        end
        throw(exception);
    else
        globalIOData=cCodeInsightObj.CodeInfo.getSLCCGlobalIOData();
    end

    globalIOs=parseGlobalIOFromJsonFormatData(globalIOData,true);
    newGlobalIOChecksum=cgxe('MD5AsString',globalIOs);
end

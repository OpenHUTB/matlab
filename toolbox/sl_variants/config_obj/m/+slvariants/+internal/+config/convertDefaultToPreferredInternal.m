function convertDefaultToPreferredInternal(modelName,varargin)

    persistent p
    if isempty(p)
        p=inputParser;
        p.FunctionName='slvariants.internal.config.convertDefaultToPreferredInternal';
        p.StructExpand=false;
        p.PartialMatching=false;
        p.addParameter('AddActivateToInitFcn',false,@(x)validateattributes(x,{'logical'},{}));
        p.addParameter('AddActivateToPostLoadFcn',false,@(x)validateattributes(x,{'logical'},{}));
    end

    try
        parse(p,varargin{:});
    catch ME
        throwAsCaller(ME);
    end

    cbToAppend=['Simulink.VariantManager.activateModel(bdroot, ','...',newline,'    ''Configuration'', ','Simulink.VariantManager.getPreferredConfigurationName(bdroot))'];

    if p.Results.AddActivateToPostLoadFcn
        currPostLoadFcn=get_param(modelName,'PostLoadFcn');
        if isempty(currPostLoadFcn)
            set_param(modelName,'PostLoadFcn',cbToAppend);
        else
            set_param(modelName,'PostLoadFcn',[currPostLoadFcn,newline,cbToAppend]);
        end
    end

    if p.Results.AddActivateToInitFcn
        currInitFcn=get_param(modelName,'InitFcn');
        if isempty(currInitFcn)
            set_param(modelName,'InitFcn',cbToAppend);
        else
            set_param(modelName,'InitFcn',[currInitFcn,newline,cbToAppend]);
        end
    end
end
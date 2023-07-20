function varargout=activateModel(modelName,varargin)






















    varargout={};



    [isInstalled,err]=slvariants.internal.utils.getVMgrInstallInfo('Simulink.VariantManager.activateModel');
    if~isInstalled
        throwAsCaller(err);
    end

    if(nargin==0)||(mod(nargin,2)==0)


        throwAsCaller(MException(message('Simulink:VariantManager:ActivateModelInvalidInputSyntax')));
    end

    if nargout>0

        throwAsCaller(MException(message('Simulink:VariantManager:ActivateModelInvalidOutputSyntax')));
    end



    persistent p
    if isempty(p)
        p=inputParser;
        p.FunctionName='Simulink.VariantManager.activateModel';
        p.StructExpand=false;
        p.PartialMatching=false;
        p.addParameter('Configuration','',@(x)validateattributes(x,{'char','string'},{}));
    end

    try
        parse(p,varargin{:});
    catch ME
        throwAsCaller(ME);
    end

    if numel(varargin)>1

        propertyNames=varargin(1:2:end);


        propertyNames=cellfun(@(name)(char(name)),propertyNames,'UniformOutput',false);
        uniquePropertyNames=unique(propertyNames,'stable');

        if numel(uniquePropertyNames)<numel(propertyNames)

            for i=1:numel(uniquePropertyNames)
                name=uniquePropertyNames{i};
                if nnz(strcmp(name,propertyNames))>1

                    messageId='Simulink:VariantManager:DuplicateProperty';
                    excepObj=MException(message(messageId,name));
                    throw(excepObj);
                end
            end
        end
    end

    if~ischar(modelName)&&~(isstring(modelName)&&isscalar(modelName))
        messageId='Simulink:Variants:InvalidModelName';
        excepObj=MException(message(messageId));
        throw(excepObj);
    end

    if~isvarname(modelName)

        excepObj=MException(message('Simulink:LoadSave:InvalidBlockDiagramName',modelName));
        throwAsCaller(excepObj);
    end

    if~bdIsLoaded(modelName)

        excepObj=MException(message('Simulink:VariantManager:ModelNotLoaded',modelName));
        throwAsCaller(excepObj);
    end

    configName=p.Results.Configuration;

    if~any(strcmp(p.UsingDefaults,'Configuration'))&&isempty(convertStringsToChars(strtrim(configName)))

        messageId='Simulink:VariantManager:EmptyConfigurationName';
        excepObj=MException(message(messageId));
        throw(excepObj);
    end

    slvariants.internal.manager.core.activateModelImpl(get_param(modelName,'handle'),configName);
end

function convert(modelName,varargin)
    modelName=convertStringsToChars(modelName);

    if nargin>1
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    try
        if nargin>1
            conversionType=varargin{1};
        else
            if Simulink.harness.internal.isSavedIndependently(modelName)
                conversionType='ExternalToInternal';
            else
                conversionType='InternalToExternal';
            end
        end

        if strcmp(conversionType,'ExternalToInternal')
            Simulink.harness.internal.convertExternalHarnesses(modelName,false);
        elseif strcmp(conversionType,'InternalToExternal')
            Simulink.harness.internal.convertInternalHarnesses(modelName,false);
        else
            DAStudio.error('Simulink:Harness:InvalidConvertOption',conversionType);
        end
    catch ME
        throwAsCaller(ME);
    end
end

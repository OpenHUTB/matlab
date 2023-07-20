





function isAutosar=IsAutosar(modelName)
    if nargin>0
        modelName=convertStringsToChars(modelName);
    end
    isAutosar=strcmp(get_param(modelName,'AutosarCompliant'),'on');

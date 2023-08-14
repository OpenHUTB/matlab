function tarStruct=copyStructFields(tarStruct,srcObj)




    if isempty(tarStruct);return;end

    warnState=warning('OFF','MATLAB:structOnObject');
    srcStruct=struct(srcObj);
    warning(warnState);

    stNames=fields(tarStruct);
    for idx=1:length(stNames)
        fieldName=stNames{idx};
        if isfield(srcStruct,fieldName)
            tarStruct.(fieldName)=srcStruct.(fieldName);
        end
    end
end

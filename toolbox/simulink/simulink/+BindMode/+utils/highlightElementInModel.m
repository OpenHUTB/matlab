

function result=highlightElementInModel(modelHandle,elementType,blockHandle,portNumber)
    model=get_param(modelHandle,'Name');
    if(strcmp(elementType,BindMode.BindableTypeEnum.SLSIGNAL.char))
        BindMode.utils.highlightSignalInModel(model,blockHandle,portNumber);
    elseif(strcmp(elementType,BindMode.BindableTypeEnum.SLPARAMETER.char)||...
        strcmp(elementType,BindMode.BindableTypeEnum.VARIABLE.char))
        blockPath=getfullname(blockHandle);
        BindMode.utils.highlightParameterInModel(model,blockPath);
    end
    result=true;
end
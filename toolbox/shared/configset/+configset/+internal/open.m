function open(model,paramName)













    if nargin==1
        paramName='';
    end

    model=strtok(model,'/');


    isProtected=slInternal('getReferencedModelFileInformation',model);
    if isProtected
        Simulink.ModelReference.ProtectedModel.openConfigSet(model,paramName);
        return
    end

    load_system(model);
    if~isempty(paramName)
        configset.highlightParameter(model,paramName);
    else
        view(getActiveConfigSet(model));
    end

function parentUUID=getParentForElement(appName,elemUUID)

    app=systemcomposer.internal.arch.load(appName);
    compArchModel=app.getCompositionArchitectureModel;
    elem=compArchModel.findElement(elemUUID);

    parentUUID='';
    if(~isempty(elem))


        parentComp=elem.getParentComponent;
        if(~isempty(parentComp))
            parentUUID=parentComp.getParentArchitecture.UUID;
        end
    end

end
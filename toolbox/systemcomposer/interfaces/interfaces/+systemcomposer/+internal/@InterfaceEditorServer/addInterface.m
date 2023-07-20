function obj=addInterface(this,interfaceType)




    obj=[];

    interfaceName=getInterfaceName(this,interfaceType);

    if~isInterfaceDictionaryContext(this)
        if strcmpi(interfaceType,'Signal')
            systemcomposer.BusObjectManager.AddInterface(this.getContextName,this.isModelContext,interfaceName);
        elseif strcmpi(interfaceType,'Physical')
            systemcomposer.BusObjectManager.AddPhysicalInterface(this.getContextName,this.isModelContext,interfaceName);
        elseif strcmpi(interfaceType,'ValueType')
            systemcomposer.BusObjectManager.AddAtomicInterface(this.getContextName,this.isModelContext,interfaceName);
        elseif strcmpi(interfaceType,'Service')
            systemcomposer.BusObjectManager.AddServiceInterface(this.getContextName,this.isModelContext,interfaceName);
        end
    else
        interfaceDictAPI=Simulink.interface.dictionary.open(this.dd.filepath());
        if strcmpi(interfaceType,'Signal')
            interfaceDictAPI.addDataInterface(interfaceName);
        elseif strcmpi(interfaceType,'ValueType')
            interfaceDictAPI.addValueType(interfaceName);
        elseif any(strcmpi(interfaceType,{'Service','Physical'}))
            assert(false,'Adding %s interface to interface dictionary is not supported.',interfaceType);
        else
            assert(false,'Unexpected interface type added: %s',interfaceType);
        end
    end

    interface=this.piCatalog.getPortInterface(interfaceName);
    if~isempty(interface)
        obj=struct('UUID',interface.UUID);
    end

end

function elementName=getInterfaceName(this,elementType)

    nameBase='interface';
    if strcmpi(elementType,'Service')
        nameBase='ServiceInterface';
    elseif isInterfaceDictionaryContext(this)&&strcmpi(elementType,'ValueType')

        nameBase='ValueType';
    end

    nameSuffix=0;
    elementName=strcat(nameBase,num2str(nameSuffix));

    if strcmp(this.context,'Model')
        [~,~,rootPiCatalog,~,~]=systemcomposer.internal.getDictionaryInfo(this.contextName,this.context);
        doesNameExist=@(name)~isempty(rootPiCatalog.getPortInterfaceInClosureByName('',name));
    else
        openPICatalogs=cellfun(@(x)systemcomposer.openDictionary(x).getImpl,Simulink.data.dictionary.getOpenDictionaryPaths);
        doesNameExist=@(name)any(arrayfun(@(dict)~isempty(dict.getPortInterfaceInClosureByName('',name)),openPICatalogs));
    end

    while doesNameExist(elementName)
        nameSuffix=nameSuffix+1;
        elementName=strcat(nameBase,num2str(nameSuffix));
    end
end

function isInterfaceDict=isInterfaceDictionaryContext(this)
    isInterfaceDict=~this.isModelContext&&...
    sl.interface.dict.api.isInterfaceDictionary(this.dd.filepath());
end



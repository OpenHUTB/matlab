function populateInterface(m3iObj,newValue)




    modelM3I=m3iObj.modelM3I;
    if~iscell(newValue)
        newValue={newValue};
    end
    switch class(m3iObj)
    case autosar.ui.metamodel.PackageString.InterfacesCell{1}
        dataElementCount=str2num(newValue{1});%#ok<ST2NM>
        for j=1:dataElementCount
            dataElement=feval(...
            autosar.ui.configuration.PackageString.DataElement,...
            modelM3I);
            dataElement.Name=strcat(...
            autosar.ui.wizard.PackageString.DataElementNewName,...
            num2str(j));
            m3iObj.DataElements.append(dataElement);
        end
    case autosar.ui.metamodel.PackageString.InterfacesCell{6}
        dataElementCount=str2num(newValue{1});%#ok<ST2NM>
        for j=1:dataElementCount
            dataElement=feval(...
            autosar.ui.configuration.PackageString.DataElement,...
            modelM3I);
            dataElement.Name=strcat(...
            autosar.ui.wizard.PackageString.NvDataNewName,...
            num2str(j));
            m3iObj.DataElements.append(dataElement);
        end
    case autosar.ui.metamodel.PackageString.InterfacesCell{2}
        opCount=str2num(newValue{1});%#ok<ST2NM>
        for j=1:opCount
            operation=feval(...
            autosar.ui.configuration.PackageString.Operation,...
            modelM3I);
            operation.Name=strcat(...
            autosar.ui.wizard.PackageString.OperationNewName,...
            num2str(j));
            m3iObj.Operations.append(operation);
        end
    case autosar.ui.metamodel.PackageString.InterfacesCell{3}
        modeGroupName=newValue{1};
        modeGroupElement=feval(...
        autosar.ui.metamodel.PackageString.ModeDeclarationGroupElementClass,...
        modelM3I);
        modeGroupElement.Name=modeGroupName;
        m3iObj.ModeGroup=modeGroupElement;
    case autosar.ui.metamodel.PackageString.InterfacesCell{5}
        dataElementCount=str2num(newValue{1});%#ok<ST2NM>
        for j=1:dataElementCount
            dataElement=feval(...
            autosar.ui.configuration.PackageString.ParameterData,...
            modelM3I);
            dataElement.Name=strcat(...
            autosar.ui.wizard.PackageString.DataElementNewName,...
            num2str(j));
            m3iObj.DataElements.append(dataElement);
        end
    case autosar.ui.metamodel.PackageString.InterfacesCell{4}
        triggersCount=str2num(newValue{1});%#ok<ST2NM>
        for j=1:triggersCount
            dataElement=feval(...
            autosar.ui.configuration.PackageString.Triggers,...
            modelM3I);
            dataElement.Name=strcat(...
            autosar.ui.wizard.PackageString.TriggersNewName,...
            num2str(j));
            m3iObj.Triggers.append(dataElement);
        end
    case autosar.ui.metamodel.PackageString.InterfacesCell{7}

        elementTypes={autosar.ui.configuration.PackageString.DataElement,...
        autosar.ui.configuration.PackageString.Operation};
        elementNames={autosar.ui.metamodel.PackageString.eventsNodeName,...
        autosar.ui.metamodel.PackageString.methodsNodeName};
        elementDefaultNames={autosar.ui.wizard.PackageString.EventNewName,...
        autosar.ui.wizard.PackageString.OperationNewName};
        for ii=1:length(newValue)
            elementCount=str2double(newValue{ii});
            for jj=1:elementCount
                element=feval(...
                elementTypes{ii},modelM3I);
                element.Name=strcat(elementDefaultNames{ii},num2str(jj));
                m3iObj.(elementNames{ii}).append(element);
            end
        end
    case autosar.ui.metamodel.PackageString.InterfacesCell{8}
        dataElementCount=str2num(newValue{1});%#ok<ST2NM>
        for j=1:dataElementCount
            dataElement=feval(...
            autosar.ui.configuration.PackageString.PersistencyData,...
            modelM3I);
            dataElement.Name=strcat(...
            autosar.ui.wizard.PackageString.DataElementNewName,...
            num2str(j));
            m3iObj.DataElements.append(dataElement);
        end
    otherwise
        assert(false,'Invalid interface');
    end
end



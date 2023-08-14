function[value,entries]=getInterfaceElementProperty(this,portElementUUID,propertyType)




    value='';
    entries=[];
    elem=this.mf0Model.findElement(portElementUUID);
    if isa(elem,'systemcomposer.architecture.model.interface.ValueTypeInterface')
        switch(propertyType)
        case 'Type'
            [value,entries]=systemcomposer.internal.getTypeAndAvailableTypes(elem);
        case 'Complexity'
            [value,entries]=getElemComplexity(elem);
        case 'Dimensions'
            value=getElemDimensions(elem);
        case 'Units'
            value=getElemUnits(elem);
        case 'Minimum'
            value=getElemMinimum(elem);
        case 'Maximum'
            value=getElemMaximum(elem);
        case 'Description'
            value=getElemDescription(elem);
        end
        return;
    elseif isa(elem,'systemcomposer.architecture.model.interface.CompositeDataInterface')
        switch(propertyType)
        case 'Type'
            value='';
            entries=systemcomposer.internal.getBuiltInDataTypeList;
        end
        return;
    elseif isa(elem,'systemcomposer.architecture.model.interface.AtomicPhysicalInterface')
        if strcmp(propertyType,'Type')
            [value,entries]=systemcomposer.internal.getTypeAndAvailableTypes(elem);
        end
        return;
    elseif isa(elem,'systemcomposer.architecture.model.design.Port')
        try
            intrf=elem.getPortInterface;
            if(intrf.isAnonymous)
                [value,entries]=this.getInterfaceElementProperty(intrf.UUID,propertyType);
            end
        catch ME
            disp(ME);

        end
        return;
    elseif isa(elem,'systemcomposer.architecture.model.swarch.FunctionElement')
        if strcmp(propertyType,'Asynchronous')
            value=elem.getAsynchronous();
            entries={true,false};
        end
        return;
    end

    if isa(elem,'systemcomposer.architecture.model.swarch.FunctionArgument')
        interfaceElemWrapper=systemcomposer.internal.propertyInspector.getElementWrapperFromType('FunctionArgument',portElementUUID,this.mf0Model);
    else
        interfaceElemWrapper=systemcomposer.internal.propertyInspector.getElementWrapperFromType('InterfaceElement',portElementUUID,this.mf0Model);
    end

    switch(propertyType)
    case 'Type'
        [value,entries]=interfaceElemWrapper.getElemType();
    case 'Complexity'
        [value,entries]=interfaceElemWrapper.getElemComplexity();
    case 'Dimensions'
        value=interfaceElemWrapper.getElemDimensions();
    case 'Units'
        value=interfaceElemWrapper.getElemUnits();
    case 'Minimum'
        value=interfaceElemWrapper.getElemMinimum();
    case 'Maximum'
        value=interfaceElemWrapper.getElemMaximum();
    case 'Description'
        value=interfaceElemWrapper.getElemDescription();
    end
end

function dimensions=getElemDimensions(obj)
    dimensions=obj.p_Dimensions();
end
function units=getElemUnits(obj)
    units=obj.p_Units();
end
function[complexity,entries]=getElemComplexity(obj)
    complexity=obj.p_Complexity();
    entries={'real','complex'};
end
function maximum=getElemMaximum(obj)
    maximum=obj.p_Maximum();
end

function minimum=getElemMinimum(obj)
    minimum=obj.p_Minimum();
end

function description=getElemDescription(obj)
    description=obj.getDescription();
end

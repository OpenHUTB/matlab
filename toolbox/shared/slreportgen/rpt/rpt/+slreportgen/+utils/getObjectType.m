function[objType]=getObjectType(obj)



    if isa(obj,'Stateflow.Object')
        if ishandle(obj)
            name=strsplit(class(obj),'.');
            name=name{end};

            objType=mlreportgen.utils.capitalizeFirstChar(name);
        else
            objType='Stateflow';
        end
    else
        objType=locResolveSimulinkType(obj);
    end
end




function objectType=locResolveSimulinkType(obj)

    if isa(obj,'Simulink.Object')
        type=get(obj,'Type');
    else
        type=get_param(obj,'Type');
    end
    switch(type)
    case 'block_diagram'
        objectType='Model';
    case 'block'
        objectType=locResolveBlockType(obj);


    otherwise
        objectType=mlreportgen.utils.capitalizeFirstChar(type);
    end
end






function objectType=locResolveBlockType(obj)



    if isstring(obj)
        obj=char(obj);
    end
    if isa(obj,'Simulink.Object')
        obj=strcat(obj.Path,'/',obj.Name);
    end
    maskObj=Simulink.Mask.get(obj);
    if~isempty(maskObj)&&~isempty(maskObj.Parameters)
        objectType='Block';
    else
        blkType=get_param(obj,'BlockType');
        if strcmp(blkType,'SubSystem')
            if slreportgen.utils.isTruthTable(obj)
                objectType='TruthTable';
            elseif slreportgen.utils.isMATLABFunction(obj)
                objectType='MATLABFunction';
            elseif slreportgen.utils.isStateTransitionTable(obj)
                objectType='StateTransitionTableBlock';
            else
                objectType='System';
            end
        elseif strcmp(blkType,'ModelReference')
            objectType='ModelReference';
        else
            objectType='Block';
        end
    end
end






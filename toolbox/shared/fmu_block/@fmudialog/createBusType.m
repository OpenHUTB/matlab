function createBusType(block)





    blkType=get_param(block,'BlockType');
    if strcmp(blkType,'FMU')==0
        throwAsCaller(MSLException([],message('FMUBlock:Tools:SpecifyFMUBlock')));
    end

    structStrInput=get_param(block,'FMUInputBusStruct');
    structStrOutput=get_param(block,'FMUOutputBusStruct');
    if(strcmp(structStrInput,'')==1||strcmp(structStrOutput,'')==1)
        throwAsCaller(MSLException([],message('FMUBlock:Tools:LoadFMUBlock')));
    end


    busPortStructureInput=eval(structStrInput);
    busPortStructureOutput=eval(structStrOutput);
    if(isempty(busPortStructureInput)&&isempty(busPortStructureOutput))
        fprintf(DAStudio.message('FMUBlock:Tools:NoStructuredSignals'));
        return;
    end


    inTree=get_param(block,'FMUInputStructure');
    inVisibility=get_param(block,'FMUInputVisibility');
    [busVisibilityInput,busVarNameInput]=loc_computeVisibilityForBus(inTree,inVisibility);
    busNameUserInput=get_param(block,'FMUInputBusObjectName');
    busNameInput=loc_determineVisibleBusAndName(busNameUserInput,busVisibilityInput,busVarNameInput);

    outTree=get_param(block,'FMUOutputStructure');
    outVisibility=get_param(block,'FMUOutputVisibility');
    [busVisibilityOutput,busVarNameOutput]=loc_computeVisibilityForBus(outTree,outVisibility);
    busNameUserOutput=get_param(block,'FMUOutputBusObjectName');
    busNameOutput=loc_determineVisibleBusAndName(busNameUserOutput,busVisibilityOutput,busVarNameOutput);



    a=[busPortStructureInput,busPortStructureOutput];
    busName=[busNameInput,busNameOutput];
    [uniqueBusName,uniqueBusIndex,allIndexMap]=unique(busName);


    for i=1:length(allIndexMap)
        if~loc_checkStructDataTypes(a{i}.value(1),a{uniqueBusIndex(allIndexMap(i))}.value(1))
            if(i>length(busPortStructureInput))
                portA=[DAStudio.message('FMUBlock:Tools:OutputPort'),' ',num2str(a{i}.port)];
            else
                portA=[DAStudio.message('FMUBlock:Tools:InputPort'),' ',num2str(a{i}.port)];
            end
            if(uniqueBusIndex(allIndexMap(i))>length(busPortStructureInput))
                portB=[DAStudio.message('FMUBlock:Tools:OutputPort'),' ',num2str(a{uniqueBusIndex(allIndexMap(i))}.port)];
            else
                portB=[DAStudio.message('FMUBlock:Tools:InputPort'),' ',num2str(a{uniqueBusIndex(allIndexMap(i))}.port)];
            end
            name=uniqueBusName{allIndexMap(i)};
            throwAsCaller(MSLException([],message('FMUBlock:Tools:BusObjectNamingClash',portA,portB,name)));
        end
    end

    for i=1:length(uniqueBusName)

        busInfo=Simulink.Bus.createObject(a{uniqueBusIndex(i)}.value);


        if strcmp(uniqueBusName{i},busInfo.busName)==0
            appendPrefixToNestedBus(a{uniqueBusIndex(i)}.value,busInfo.busName);
            evalin('base',[uniqueBusName{i},'=',busInfo.busName,'; clear ',busInfo.busName,';']);
            if(uniqueBusIndex(i)>length(busPortStructureInput))
                iostring=DAStudio.message('FMUBlock:Tools:BusObjectForOutputPort');
            else
                iostring=DAStudio.message('FMUBlock:Tools:BusObjectForInputPort');
            end
            fprintf([iostring,' %d: %s\n'],a{uniqueBusIndex(i)}.port,uniqueBusName{i});
        end
    end

end

function busObj=appendPrefixToNestedBus(busStruct,busName)
    busName=strtrim(busName);
    busObj=evalin('base',busName);
    N=length(busObj.Elements);
    for idx=1:N
        busElementName=busObj.Elements(idx).Name;
        busStructValue=busStruct.(busElementName);
        if isa(busStructValue,'struct')
            nestedBusName=busObj.Elements(idx).DataType;
            if~startsWith(nestedBusName,'Bus:')
                busObj.Elements(idx).DataType=['Bus: ',nestedBusName];
            end
            appendPrefixToNestedBus(busStructValue,extractAfter(busObj.Elements(idx).DataType,'Bus:'));
        end
    end
    assignin('base',busName,busObj);
end

function result=loc_checkStructDataTypes(sA,sB)


    if~isequal(size(sA),size(sB))
        result=false;
        return;
    end

    if~strcmp(class(sA),class(sB))
        result=false;
        return;
    end

    if~isstruct(sA)
        result=true;
        return;
    end

    structNamesA=fieldnames(sA);
    structNamesB=fieldnames(sB);
    if~isequal(structNamesA,structNamesB)
        result=false;
        return;
    end

    for i=1:numel(structNamesA)

        if~loc_checkStructDataTypes(sA.(structNamesA{i})(1),sB.(structNamesA{i})(1))
            result=false;
            return;
        end
    end
    result=true;
    return;
end

function[busVisibility,busVarName]=loc_computeVisibilityForBus(nodeTree,rootVisibility)
    flag=zeros(1,length(nodeTree));
    for i=1:length(nodeTree)
        if~isempty(nodeTree(i).ChildrenIndex)

            flag(nodeTree(i).ChildrenIndex)=1;
        end
    end

    rootCounter=1;
    busVisibility=zeros([1,0],'logical');
    busVarName={};
    busXMLCounter=1;
    for i=1:length(nodeTree)
        if flag(i)~=0
            continue;
        end

        if~isempty(nodeTree(i).ChildrenIndex)
            busVarName=[busVarName,nodeTree(i).VarName];
            if isempty(rootVisibility)||length(rootVisibility)<rootCounter
                busVisibility(busXMLCounter)=true;
            else
                busVisibility(busXMLCounter)=logical(rootVisibility{rootCounter});
            end
            busXMLCounter=busXMLCounter+1;
        end
        rootCounter=rootCounter+1;
    end
end

function[busName]=loc_determineVisibleBusAndName(busNameUser,busVisibility,busVarName)
    busName=cell(1,length(busVisibility));
    for i=1:length(busVisibility)
        if(isequal(busNameUser,[])||length(busNameUser)<i||isempty(busNameUser{i}))
            busName{i}=busVarName{i};
        else
            busName{i}=busNameUser{i};
        end
    end
    busName=busName(busVisibility);
end
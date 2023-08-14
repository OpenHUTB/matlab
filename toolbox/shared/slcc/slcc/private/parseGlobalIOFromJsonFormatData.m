function globalIOs=parseGlobalIOFromJsonFormatData(data,isJsonFormat)
    globalIOMap=createGlobalIOMap(data,isJsonFormat);
    globalIOs.map=convertMapToGlobalIOList(globalIOMap);
end

function globalIOMap=createGlobalIOMap(data,isJsonFormat)
    globalIOMap=containers.Map;
    if isJsonFormat
        for j=1:length(data.GlobalDictionary)
            fcnName=char(data.GlobalDictionary(j).Function);
            varName=char(data.GlobalDictionary(j).Name);
            direction=char(data.GlobalDictionary(j).AccessMode);

            if~globalIOMap.isKey(fcnName)
                globalIOMap(fcnName)=struct('GlobalRead',{{}},'GlobalWrite',{{}},...
                'Callees',{{}});
            end

            if strcmp(direction,'Read')
                record=globalIOMap(fcnName);
                record.GlobalRead=[record.GlobalRead,varName];
                globalIOMap(fcnName)=record;
            else
                record=globalIOMap(fcnName);
                record.GlobalWrite=[record.GlobalWrite,varName];
                globalIOMap(fcnName)=record;
            end
        end

        for j=1:length(data.CallTree)
            caller=data.CallTree(j).CallerFunction;
            callee=char(data.CallTree(j).CalleeFunction);
            if~globalIOMap.isKey(caller)
                globalIOMap(caller)=struct('GlobalRead',{{}},'GlobalWrite',{{}},...
                'Callees',{{}});
            end
            record=globalIOMap(caller);
            record.Callees=[record.Callees,callee];
            globalIOMap(caller)=record;
        end
    else

        for j=1:length(data.GlobalDictionary)
            fcnName=data.GlobalDictionary{j}{1};
            varName=data.GlobalDictionary{j}{2};
            direction=data.GlobalDictionary{j}{3};

            if~globalIOMap.isKey(fcnName)
                globalIOMap(fcnName)=struct('GlobalRead',{{}},'GlobalWrite',{{}},...
                'Callees',{{}});
            end

            if strcmp(direction,'Read')
                record=globalIOMap(fcnName);
                record.GlobalRead=[record.GlobalRead,varName];
                globalIOMap(fcnName)=record;
            else
                record=globalIOMap(fcnName);
                record.GlobalWrite=[record.GlobalWrite,varName];
                globalIOMap(fcnName)=record;
            end
        end

        for j=1:length(data.CallTree)
            caller=data.CallTree{j}{1};
            callee=data.CallTree{j}{2};
            if~globalIOMap.isKey(caller)
                globalIOMap(caller)=struct('GlobalRead',{{}},'GlobalWrite',{{}},...
                'Callees',{{}});
            end
            record=globalIOMap(caller);
            record.Callees=[record.Callees,callee];
            globalIOMap(caller)=record;
        end
    end
end

function globalIOs=convertMapToGlobalIOList(globalIOMap)
    allFunctions=globalIOMap.keys();
    numFunctions=length(allFunctions);
    globalIOs=struct('Function',cell(1,numFunctions),'GlobalIn',cell(1,numFunctions),...
    'GlobalOut',cell(1,numFunctions));
    for j=1:numFunctions
        functionName=allFunctions{j};
        callees=getAllCallees(globalIOMap(functionName).Callees,globalIOMap,{functionName});
        [collatedGlobalIn,collatedGlobalOut]=collateCalleeGlobalIO(callees,globalIOMap);
        collatedGlobalIn=unique([globalIOMap(functionName).GlobalRead,collatedGlobalIn],'stable');
        collatedGlobalOut=unique([globalIOMap(functionName).GlobalWrite,collatedGlobalOut],'stable');
        globalIOs(j).Function=functionName;
        globalIOs(j).GlobalIn=collatedGlobalIn;
        globalIOs(j).GlobalOut=collatedGlobalOut;
    end
end

function[collatedGlobalIn,collatedGlobalOut]=collateCalleeGlobalIO(callees,globalIOMap)
    collatedGlobalIn=[];
    collatedGlobalOut=[];

    for j=1:length(callees)
        if~globalIOMap.isKey(callees{j})
            continue;
        end
        collatedGlobalIn=[collatedGlobalIn,globalIOMap(callees{j}).GlobalRead];%#ok<AGROW>
        collatedGlobalOut=[collatedGlobalOut,globalIOMap(callees{j}).GlobalWrite];%#ok<AGROW>
    end
    collatedGlobalIn=unique(collatedGlobalIn,'stable');
    collatedGlobalOut=unique(collatedGlobalOut,'stable');

end

function allCallees=getAllCallees(topLevelCallees,globalIOMap,visited)
    allCallees=topLevelCallees;
    for j=1:length(topLevelCallees)
        aCallee=topLevelCallees{j};
        if globalIOMap.isKey(aCallee)&&~ismember(aCallee,visited)
            allCallees=[allCallees,globalIOMap(aCallee).Callees];%#ok<AGROW>
        end
        if~ismember(aCallee,visited)
            visited=[visited,aCallee];%#ok<AGROW>
        end
    end
    allCallees=unique(allCallees,'stable');
    done=true;
    for k=1:length(allCallees)
        if~ismember(allCallees{k},visited)
            done=false;
            break;
        end
    end
    if~done
        allCallees=getAllCallees(allCallees,globalIOMap,visited);
    end
end

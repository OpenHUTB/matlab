function deps=analyzeBusObjects(busNode,fileNode,buses,baseType)



    import dependencies.internal.buses.util.BusTypes;

    analysisInfo=struct;

    analysisInfo.BusNode=busNode;
    analysisInfo.FileNode=fileNode;

    [analysisInfo.BusName,analysisInfo.HasElement,...
    analysisInfo.ElementName]=i_parse(busNode.Location);

    if analysisInfo.HasElement
        analysisInfo.BusDataTypePattern=missing;
    else
        analysisInfo.BusDataTypePattern=...
        BusTypes.getBusDataTypePattern(analysisInfo.BusName);
    end

    analysisInfo.Type=baseType+","+BusTypes.BusObjectSubType;

    deps=i_analyze(analysisInfo,buses);
end

function[busName,hasElement,elementName]=i_parse(busNodeLocation)
    busName=busNodeLocation{1};

    hasElement=length(busNodeLocation)>1;

    if hasElement
        elementName=busNodeLocation{2};
    else
        elementName=missing;
    end
end

function deps=i_analyze(analysisInfo,busStruct)
    deps=dependencies.internal.graph.Dependency.empty;

    for varName=string(fieldnames(busStruct))'
        busVar=busStruct.(varName);
        busVar=busVar(:)';
        for bus=busVar
            deps=[deps,i_analyzeBus(analysisInfo,bus,varName)];%#ok<AGROW>
        end
    end

end

function deps=i_analyzeBus(analysisInfo,bus,varName)
    if analysisInfo.HasElement
        deps=i_findElementDependencies(analysisInfo,bus,varName);
    else
        deps=i_findBusDependencies(analysisInfo,bus,varName);
    end
end

function deps=i_findElementDependencies(analysisInfo,bus,varName)
    if any(strcmp({bus.Elements.Name},analysisInfo.ElementName))
        if strcmp(analysisInfo.BusName,varName)
            busNode=analysisInfo.BusNode;
        else
            busNode=dependencies.internal.graph.Nodes.createVariableNode(...
            [varName,analysisInfo.ElementName]);
        end
        deps=i_createDep(analysisInfo,"",busNode);
    else
        deps=dependencies.internal.graph.Dependency.empty;
    end
end

function deps=i_findBusDependencies(analysisInfo,bus,varName)
    import dependencies.internal.buses.util.regexpmatch;


    if strcmp(varName,analysisInfo.BusName)
        deps=i_createDep(analysisInfo,varName);
    else
        deps=dependencies.internal.graph.Dependency.empty;
    end


    matchingElements=regexpmatch({bus.Elements.DataType},...
    analysisInfo.BusDataTypePattern);

    if any(matchingElements)
        paths=varName+"."+{bus.Elements(matchingElements).Name};
        deps=[deps,arrayfun(@(path)i_createDep(analysisInfo,path),paths)];
    end
end

function dep=i_createDep(analysisInfo,path,busNode)
    if nargin<3
        busNode=analysisInfo.BusNode;
    end

    dep=dependencies.internal.graph.Dependency(...
    analysisInfo.FileNode,path,busNode,"",...
    analysisInfo.Type,"Bus");
end

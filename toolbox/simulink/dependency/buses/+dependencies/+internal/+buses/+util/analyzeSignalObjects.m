function deps=analyzeSignalObjects(busNode,fileNode,signals,baseType)




    deps=dependencies.internal.graph.Dependency.empty;

    import dependencies.internal.buses.util.BusTypes;
    subType=BusTypes.SignalObjectSubType;
    type=baseType+","+subType;
    busTypePattern=BusTypes.getBusDataTypePattern(busNode.Location{1});

    busElement=busNode.Location{end};

    import dependencies.internal.buses.util.CodeUtils;
    for name=string(fieldnames(signals))'

        if(strcmp(name,busElement))
            deps(end+1)=dependencies.internal.graph.Dependency(...
            fileNode,name,busNode,"",type,"Bus");%#ok<AGROW>
        end

        signalVar=signals.(name);
        signalVar=signalVar(:)';

        for signal=signalVar
            if~isempty(regexp(signal.DataType,busTypePattern,"once"))&&...
                (length(busNode.Location)==1||...
                CodeUtils.codeMatch(signal.InitialValue,busElement))
                deps(end+1)=dependencies.internal.graph.Dependency(...
                fileNode,name,busNode,"",type,"Bus");%#ok<AGROW>
            end
        end
    end

end

function deps=analyzeBusElementObjects(busNode,fileNode,elements,baseType)



    import dependencies.internal.buses.util.BusTypes;
    import dependencies.internal.buses.util.regexpmatch

    deps=dependencies.internal.graph.Dependency.empty;

    busName=busNode.Location{1};
    subType=BusTypes.BusElementObjectSubType;
    type=strcat(baseType,",",subType);
    busDataTypePattern=BusTypes.getBusDataTypePattern(busName);

    for name=string(fieldnames(elements))'
        element=elements.(name);

        if length(busNode.Location)>1
            busElement=busNode.Location{end};
            if strcmp(name,busElement)




                deps(end+1)=dependencies.internal.graph.Dependency(...
                fileNode,"",busNode,"",type,"Bus");%#ok<AGROW>
            end
            if any(strcmp({element.Name},busElement))
                deps(end+1)=dependencies.internal.graph.Dependency(...
                fileNode,name,busNode,"",type,"Bus");%#ok<AGROW>
            end

        else
            if any(regexpmatch({element.DataType},busDataTypePattern))
                deps(end+1)=dependencies.internal.graph.Dependency(...
                fileNode,name,busNode,"",type,"Bus");%#ok<AGROW>
            end
        end

    end

end

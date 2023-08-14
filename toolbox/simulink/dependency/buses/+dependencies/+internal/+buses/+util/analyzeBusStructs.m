function deps=analyzeBusStructs(busNode,fileNode,structs,baseType)




    elementName=string(busNode.Location{end});
    matchingNames=i_recursivelyFindMatchingNames("",elementName,structs);
    subType=dependencies.internal.buses.util.BusTypes.StructSubType;
    type=baseType+","+subType;

    deps=arrayfun(@(name)dependencies.internal.graph.Dependency(...
    fileNode,name,busNode,"",type,"Bus"),matchingNames);
end


function names=i_recursivelyFindMatchingNames(name,elementName,structure)
    fields=string(fieldnames(structure))';
    if any(strcmp(fields,elementName))
        names=name+elementName;
    else
        names=[];
    end

    structFields=fields(arrayfun(@(field)isstruct(structure.(field)),fields));

    for field=structFields
        newName=strcat(name,field,".");
        newStructures=structure.(field);
        newStructures=newStructures(:)';
        for newStructure=newStructures
            names=[names,i_recursivelyFindMatchingNames(newName,...
            elementName,newStructure)];%#ok<AGROW>
        end
    end
end

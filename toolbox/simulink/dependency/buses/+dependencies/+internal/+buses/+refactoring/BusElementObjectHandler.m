classdef BusElementObjectHandler<dependencies.internal.buses.refactoring.VariableHandler




    properties(Constant)
        SubType=dependencies.internal.buses.util.BusTypes.BusElementObjectSubType;
    end

    methods

        function refactor(~,dependency,newElements,fileHandler)
            import dependencies.internal.buses.util.BusTypes;

            location=dependency.UpstreamNode.Location;
            if~isempty(location)
                location=location{1};
            end

            bus=string(dependency.DownstreamNode.Location);
            oldName=bus(end);

            newName=newElements(end);

            variableName=char(dependency.UpstreamComponent.Path);

            if length(bus)==1

                busDataTypePattern=BusTypes.getBusDataTypePattern(oldName);
                modifyFunc=@(elements)i_replaceDataType(elements,busDataTypePattern,newName);
                fileHandler.modifyObject(location,variableName,modifyFunc);

            else

                if strcmp(variableName,"")

                    fileHandler.changeName(location,oldName,newName);
                else
                    modifyFunc=@(elements)i_replaceElementName(elements,oldName,newName);
                    fileHandler.modifyObject(location,variableName,modifyFunc);
                end

            end
        end

    end

end

function elements=i_replaceDataType(elements,pattern,newName)
    import dependencies.internal.buses.util.regexpmatch
    needUpdate=regexpmatch({elements.DataType},pattern);
    if any(needUpdate)
        elements(needUpdate).DataType=strcat("Bus: ",newName);
    end
end

function elements=i_replaceElementName(elements,elementName,newElementName)
    needUpdate=strcmp({elements.Name},elementName);
    if any(needUpdate)
        elements(needUpdate).Name=newElementName;
    end
end

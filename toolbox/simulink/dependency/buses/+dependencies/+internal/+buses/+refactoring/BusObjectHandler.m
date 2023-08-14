classdef BusObjectHandler<dependencies.internal.buses.refactoring.VariableHandler




    properties(Constant)
        SubType=dependencies.internal.buses.util.BusTypes.BusObjectSubType;
    end

    methods

        function refactor(~,dependency,newElements,fileHandler)
            import dependencies.internal.buses.util.BusTypes;

            location=dependency.UpstreamNode.Location;
            if~isempty(location)
                location=location{1};
            end

            bus=string(dependency.DownstreamNode.Location);
            busName=bus(1);

            newName=newElements(end);

            if length(bus)==1

                source=split(dependency.UpstreamComponent.Path,".");

                if length(source)==1

                    fileHandler.changeName(location,busName,newName);
                else

                    busDataTypePattern=BusTypes.getBusDataTypePattern(busName);
                    newBusName=source(1);
                    elementName=source(2);
                    modifyFunc=@(buses)i_replaceDataTypeOnMultipleBuses(buses,...
                    busDataTypePattern,elementName,newName);
                    fileHandler.modifyObject(location,newBusName,modifyFunc);
                end

            else

                oldElementName=bus(2);
                modifyFunc=@(buses)i_replaceElementNameOnMultipleBuses(buses,...
                oldElementName,newName);
                fileHandler.modifyObject(location,busName,modifyFunc);
            end
        end

    end

end

function busObjs=i_replaceDataTypeOnMultipleBuses(busObjs,pattern,elementName,newName)
    busObjs=arrayfun(@(bus)i_replaceDataType(bus,pattern,elementName,newName),busObjs);
end

function busObj=i_replaceDataType(busObj,pattern,elementName,newName)
    needUpdate=i_hasExpectedNameAndType(busObj.Elements,elementName,pattern);
    if any(needUpdate)
        busObj.Elements(needUpdate).DataType=strcat("Bus: ",newName);
    end
end

function yesNo=i_hasExpectedNameAndType(elements,elementName,pattern)
    import dependencies.internal.buses.util.regexpmatch;
    yesNo=strcmp({elements.Name},elementName)&...
    regexpmatch({elements.DataType},pattern);
end

function busObjs=i_replaceElementNameOnMultipleBuses(busObjs,elementName,newElementName)
    busObjs=arrayfun(@(bus)i_replaceElementName(bus,elementName,newElementName),busObjs);
end

function busObj=i_replaceElementName(busObj,elementName,newElementName)
    needUpdate=strcmp({busObj.Elements.Name},elementName);
    if any(needUpdate)
        busObj.Elements(needUpdate).Name=newElementName;
    end
end

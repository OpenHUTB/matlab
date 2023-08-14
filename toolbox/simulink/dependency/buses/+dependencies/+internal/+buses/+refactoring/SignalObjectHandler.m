classdef SignalObjectHandler<dependencies.internal.buses.refactoring.VariableHandler




    properties(Constant)
        SubType=dependencies.internal.buses.util.BusTypes.SignalObjectSubType;
    end

    methods
        function refactor(~,dependency,newElements,fileHandler)
            location=dependency.UpstreamNode.Location;
            if~isempty(location)
                location=location{1};
            end

            variableName=dependency.UpstreamComponent.Path;
            oldBus=dependency.DownstreamNode;
            oldBusName=oldBus.Location{1};
            oldName=oldBus.Location{end};
            newName=newElements(end);

            import dependencies.internal.buses.util.BusTypes;
            busDataTypePattern=BusTypes.getBusDataTypePattern(oldBusName);

            modifyFunc=@(signals)i_updateSignals(signals,...
            busDataTypePattern,oldBus,newName);

            fileHandler.modifyObject(location,variableName,modifyFunc);


            if strcmp(oldName,variableName)
                fileHandler.changeName(location,variableName,newName);
            end

        end
    end
end

function signals=i_updateSignals(signals,pattern,oldBus,newName)
    import dependencies.internal.buses.util.regexpmatch;
    needUpdate=regexpmatch({signals.DataType},pattern);

    if~any(needUpdate)
        return;
    end

    if length(oldBus.Location)==1
        signals(needUpdate).DataType=strcat("Bus: ",newName);
    else
        oldName=oldBus.Location{end};
        import dependencies.internal.buses.util.CodeUtils;
        signals(needUpdate).InitialValue=CodeUtils.refactorCode(...
        signals(needUpdate).InitialValue,oldName,char(newName));
    end
end

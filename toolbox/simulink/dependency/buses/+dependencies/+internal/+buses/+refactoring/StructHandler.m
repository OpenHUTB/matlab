classdef StructHandler<dependencies.internal.buses.refactoring.VariableHandler




    properties(Constant)
        SubType=dependencies.internal.buses.util.BusTypes.StructSubType;
    end

    methods

        function refactor(~,dependency,newElements,fileHandler)
            location=dependency.UpstreamNode.Location;
            if~isempty(location)
                location=location{1};
            end

            oldStructFields=split(dependency.UpstreamComponent.Path,".");
            oldName=oldStructFields(1);

            newName=newElements(end);

            if length(oldStructFields)==1
                fileHandler.changeName(location,oldName,newName)
            else
                oldStructFields=oldStructFields(2:end);
                import dependencies.internal.buses.util.recursivelyReplaceStructureElements;
                updateStructFunc=@(data)recursivelyReplaceStructureElements(data,oldStructFields,newName);
                fileHandler.modifyObject(location,oldName,updateStructFunc)
            end

        end

    end

end

classdef StateflowDataHandler<dependencies.internal.action.RefactoringHandler




    properties(SetAccess=immutable)
        Types=cellstr(dependencies.internal.buses.analysis.StateflowDataAnalyzer.DataType);
        RenameOnly=true;
    end

    methods

        function refactor(~,dependency,newName)
            import dependencies.internal.util.getStateflowObject;
            [~,model,~]=fileparts(dependency.UpstreamNode.Location{1});
            obj=getStateflowObject(dependency.UpstreamComponent.Path,model);

            if isempty(obj)
                return;
            end

            oldElement=obj.get('DataType');

            if startsWith(oldElement,"Bus:")
                newName=strcat("Bus: ",newName);
            end
            obj.set('DataType',char(newName));
        end

    end

end

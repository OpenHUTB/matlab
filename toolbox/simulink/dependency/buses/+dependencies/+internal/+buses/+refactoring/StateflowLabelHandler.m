classdef StateflowLabelHandler<dependencies.internal.action.RefactoringHandler




    properties(SetAccess=immutable)
        Types=i_getTypes();
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

            label=obj.get('LabelString');

            busNode=dependency.DownstreamNode;

            if length(busNode.Location)>1
                patStart="(\.)";
            else
                patStart="(^|[^\w\.])";
            end

            pattern=strcat(patStart,busNode.Location{end},"([^\w:]|$)");

            newElement=string(split(newName,"."));
            newElement=newElement(end);

            newLabel=regexprep(label,pattern,"$1"+newElement+"$2");

            obj.set('LabelString',char(newLabel));
        end

    end

end

function types=i_getTypes()
    import dependencies.internal.buses.analysis.StateflowStatesAndTransitionsAnalyzer;
    types=cellstr([
    StateflowStatesAndTransitionsAnalyzer.StateType
    StateflowStatesAndTransitionsAnalyzer.TransitionType
    ]);
end

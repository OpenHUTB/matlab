classdef MatlabFunctionHandler<dependencies.internal.action.RefactoringHandler




    properties(SetAccess=immutable)
        Types=i_getTypes();
        RenameOnly=true;
    end

    methods
        function refactor(~,dependency,newName)
            oldElement=dependency.DownstreamNode.Location{end};

            newElement=split(newName,'.');
            newElement=newElement{end};

            import dependencies.internal.action.dependency.MatlabFunctionHandler;
            [sid,isMATLABFcn]=MatlabFunctionHandler.getBlockSID(dependency);

            if isMATLABFcn
                sid=strcat(sid,":1");
            end

            handle=Simulink.ID.getHandle(sid);

            text=handle.Script;

            import dependencies.internal.buses.util.CodeUtils;
            updated=CodeUtils.refactorCode(text,oldElement,newElement);

            handle.Script=updated;
        end
    end
end

function types=i_getTypes()
    import dependencies.internal.buses.analysis.StateflowMATLABFunctionsAnalyzer;
    types=cellstr([
    StateflowMATLABFunctionsAnalyzer.MATLABFcnType
    StateflowMATLABFunctionsAnalyzer.StateflowMATLABFcnType
    ]);
end

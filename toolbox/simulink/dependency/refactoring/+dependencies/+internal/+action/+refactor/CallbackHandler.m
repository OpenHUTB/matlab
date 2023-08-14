classdef CallbackHandler<dependencies.internal.action.RefactoringHandler




    properties(SetAccess=immutable)
        Types=i_getTypes();
        RenameOnly=true;
    end

    methods

        function refactor(~,dependency,newPath)
            types=dependency.Type.Parts;
            if length(types)==3
                callbackType=types(2);

                component=dependency.UpstreamComponent.Path;
                if component==""
                    [~,component]=fileparts(dependency.UpstreamNode.Location{1});
                end
                text=get_param(component,callbackType);

                updated=dependencies.internal.action.refactor.updateMatlabCode(...
                dependency.UpstreamNode,text,dependency.DownstreamNode,newPath,false);

                set_param(component,callbackType,updated);
            end
        end

    end

end


function types=i_getTypes()
    import dependencies.internal.analysis.simulink.ModelCallbackAnalyzer;
    import dependencies.internal.analysis.simulink.BlockCallbackAnalyzer;
    types=[
    "ModelCallback,"+ModelCallbackAnalyzer.ModelCallbacks(:)
    "BlockCallback,"+BlockCallbackAnalyzer.BlockCallbacks(:)
    "BlockCallback,"+BlockCallbackAnalyzer.SubSystemCallbacks(:)
    "AnnotationCallback,"+BlockCallbackAnalyzer.AnnotationCallbacks(:)
    ];
    types=cellstr(types+",FunctionCall");
end

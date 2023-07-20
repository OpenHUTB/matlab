classdef CallbackHandler<dependencies.internal.action.RefactoringHandler




    properties(SetAccess=immutable)
        Types=i_getTypes();
        RenameOnly=true;
    end

    methods

        function refactor(~,dependency,newName)
            subtypes=dependency.Type.Parts;
            callback=subtypes(2);

            oldElement=dependency.DownstreamNode.Location{end};

            newElement=split(newName,'.');
            newElement=newElement{end};

            component=dependency.UpstreamComponent.Path;

            if component==""
                [~,component]=fileparts(dependency.UpstreamNode.Location{1});
            end
            text=get_param(component,callback);

            import dependencies.internal.buses.util.CodeUtils;
            updated=CodeUtils.refactorCode(text,oldElement,newElement);

            set_param(component,callback,updated);
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
    types=cellstr(types);
end

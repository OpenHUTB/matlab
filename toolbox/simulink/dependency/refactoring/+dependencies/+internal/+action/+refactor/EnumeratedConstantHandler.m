classdef EnumeratedConstantHandler<dependencies.internal.action.RefactoringHandler




    properties(SetAccess=immutable)
        Types=cellstr(dependencies.internal.analysis.simulink.EnumeratedConstantAnalyzer.EnumeratedConstantType.ID);
        RenameOnly=true;
    end

    methods

        function refactor(~,dependency,newPath)
            block=dependency.UpstreamComponent.Path;
            [~,oldRef]=fileparts(dependency.DownstreamNode.Location{1});
            [~,newRef]=fileparts(newPath);
            newType="Enum: "+newRef;

            value=i_getParamIfAny(block,"Value");
            if contains(value,oldRef)
                set_param(block,"OutDataTypeStr",newType,"Value",strrep(value,oldRef,newRef));
            else
                set_param(block,"OutDataTypeStr",newType);
            end

        end

    end

end

function value=i_getParamIfAny(block,param)
    value='';
    if any(strcmp(fieldnames(get_param(block,"ObjectParameters")),param))
        value=get_param(block,param);
    end
end

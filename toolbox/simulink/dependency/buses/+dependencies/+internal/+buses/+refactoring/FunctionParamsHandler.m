classdef FunctionParamsHandler<dependencies.internal.action.RefactoringHandler




    properties(SetAccess=immutable)
        Types;
        RenameOnly;
    end

    properties(SetAccess=immutable,GetAccess=private)
        Params(1,:)string;
        GraphTypes(1,:)dependencies.internal.graph.Type;
    end

    methods
        function this=FunctionParamsHandler()
            import dependencies.internal.buses.util.BusTypes;
            this.RenameOnly=true;
            typeStr=[BusTypes.InitValue.depType,BusTypes.CodeInParam.depType];
            this.GraphTypes=arrayfun(@dependencies.internal.graph.Type,typeStr);
            this.Params=[BusTypes.InitValue.param,BusTypes.CodeInParam.param];
            this.Types=cellstr(typeStr');
        end

        function refactor(this,dependency,newName)
            oldElement=dependency.DownstreamNode.Location{end};

            newElement=split(newName,'.');
            newElement=newElement{end};

            component=dependency.UpstreamComponent.Path;

            param=this.Params(this.GraphTypes==dependency.Type);
            text=get_param(component,param);

            import dependencies.internal.buses.util.CodeUtils;
            updated=CodeUtils.refactorCode(text,oldElement,newElement);

            set_param(component,param,updated);
        end
    end
end

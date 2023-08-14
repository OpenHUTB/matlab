classdef OutDataTypeHandler<dependencies.internal.action.RefactoringHandler




    properties(SetAccess=immutable)
        Types;
        RenameOnly;
    end

    properties(SetAccess=immutable,GetAccess=private)
        Params(1,:)string;
        GraphTypes(1,:)dependencies.internal.graph.Type;
    end

    methods
        function this=OutDataTypeHandler()
            import dependencies.internal.buses.util.BusTypes;
            this.RenameOnly=true;
            typeStr=[BusTypes.OutDataTypeTypes.depType];
            this.GraphTypes=arrayfun(@dependencies.internal.graph.Type,typeStr);
            this.Params=[BusTypes.OutDataTypeTypes.param];
            this.Types=cellstr(typeStr');
        end

        function refactor(this,dependency,newName)
            component=dependency.UpstreamComponent.Path;

            param=this.Params(this.GraphTypes==dependency.Type);
            oldElement=get_param(component,param);

            if startsWith(oldElement,"Bus:")
                newName=strcat("Bus: ",newName);
            end
            set_param(component,param,newName);
        end

    end

end

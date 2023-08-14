classdef SymbolSeparatedParamsHandler<dependencies.internal.action.RefactoringHandler




    properties(SetAccess=immutable)
        Types;
        RenameOnly;
    end

    properties(SetAccess=immutable,GetAccess=private)
        Handlers(1,:)struct;
        GraphTypes(1,:)dependencies.internal.graph.Type;
    end

    methods
        function this=SymbolSeparatedParamsHandler()
            this.RenameOnly=true;
            this.Handlers=dependencies.internal.buses.util.BusTypes.SymbolSeparated;
            typeStr=[this.Handlers.depType];
            this.GraphTypes=arrayfun(@dependencies.internal.graph.Type,typeStr);
            this.Types=cellstr(typeStr');
        end

        function refactor(this,dependency,newName)
            handler=this.Handlers(this.GraphTypes==dependency.Type);

            component=dependency.UpstreamComponent.Path;
            signals=string(split(get_param(component,handler.param),handler.symbol));
            matchingSignal=dependency.DownstreamComponent.Path;

            oldElement=dependency.DownstreamNode.Location(end);
            newElement=string(split(newName,"."));
            newElement=newElement(end);

            newSignal=regexprep(matchingSignal,...
            strcat("^('?(?:\w+\.)*)",oldElement,"((?:\.\w+)*'?)$"),...
            strcat("$1",newElement,"$2"));

            signals(strcmp(signals,matchingSignal))=newSignal;

            set_param(component,handler.param,join(signals,handler.symbol));
        end

    end

end

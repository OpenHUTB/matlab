classdef(ConstructOnLoad=true)Inport<eda.internal.component.Port







    properties

    end

    methods
        function this=Inport(varargin)
            if~isempty(varargin)
                arg=this.componentArg(varargin);
                componentSet(this,arg);
            end
        end
    end

    methods(Access=private)

    end
end


classdef(ConstructOnLoad=true)Outport<eda.internal.component.Port







    properties

    end

    methods
        function this=Outport(varargin)
            if~isempty(varargin)
                arg=this.componentArg(varargin);
                componentSet(this,arg);
            end
        end

    end

    methods(Access=private)

    end
end


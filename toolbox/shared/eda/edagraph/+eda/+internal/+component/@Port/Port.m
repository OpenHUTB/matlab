classdef(ConstructOnLoad=true)Port<eda.internal.component.WhiteBox







    properties
PIN
FiType
signal
    end

    methods
        function this=Port(varargin)
            if~isempty(varargin)
                arg=this.componentArg(varargin);
                componentSet(this,arg);
            end
        end

        arg=portArg(varargin);
    end

    methods(Access=private)

    end
end


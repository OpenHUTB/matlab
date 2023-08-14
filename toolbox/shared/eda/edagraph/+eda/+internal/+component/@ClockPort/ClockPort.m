classdef(ConstructOnLoad=true)ClockPort<eda.internal.component.Port







    properties
ClockPeriod
    end

    methods
        function this=ClockPort(varargin)
            this.FiType='boolean';
            if~isempty(varargin)
                arg=this.componentArg(varargin);
                if isfield(arg,'FiType')
                    warning(message('EDALink:ClockPort:ClockPort:ClockPortType'));
                end
                componentSet(this,arg);
            end
        end
    end

    methods(Access=private)

    end
end


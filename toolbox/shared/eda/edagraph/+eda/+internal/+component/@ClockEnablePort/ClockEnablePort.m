classdef(ConstructOnLoad=true)ClockEnablePort<eda.internal.component.Port







    properties

    end

    methods
        function this=ClockEnablePort(varargin)
            this.FiType='boolean';
            if~isempty(varargin)
                arg=this.componentArg(varargin);
                if isfield(arg,'FiType')
                    warning(message('EDALink:ClockEnablePort:ClockEnablePort:ClockEnablePortType'));
                end
                componentSet(this,arg);
            end
        end
    end

    methods(Access=private)

    end
end


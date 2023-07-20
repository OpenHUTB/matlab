classdef(ConstructOnLoad=true)ResetPort<eda.internal.component.Port








    properties

    end

    methods
        function this=ResetPort(varargin)
            this.FiType='boolean';
            if~isempty(varargin)
                arg=this.componentArg(varargin);
                if isfield(arg,'FiType')
                    warning(message('EDALink:ResetPort:ResetPort:ResetPortType'));
                end
                componentSet(this,arg);
            end
        end
    end

    methods(Access=private)

    end
end


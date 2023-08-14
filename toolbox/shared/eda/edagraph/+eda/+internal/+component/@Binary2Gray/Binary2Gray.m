classdef(ConstructOnLoad)Binary2Gray<eda.internal.component.WhiteBox



    properties
clk
rst
binary_in
gray_out

        generic=generics('DATAWIDTH','integer','8');
    end

    methods
        function this=Binary2Gray(varargin)
            this.setGenerics(varargin);
            this.clk=eda.internal.component.ClockPort;
            this.rst=eda.internal.component.ResetPort;
            this.binary_in=eda.internal.component.Inport('FiType',this.generic.DATAWIDTH);
            this.gray_out=eda.internal.component.Outport('FiType',this.generic.DATAWIDTH);
        end

    end

end


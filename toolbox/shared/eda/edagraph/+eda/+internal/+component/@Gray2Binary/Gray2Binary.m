classdef(ConstructOnLoad)Gray2Binary<eda.internal.component.WhiteBox



    properties
clk
rst
gray_in
binary_out

        generic=generics('DATAWIDTH','integer','8');
    end

    methods
        function this=Gray2Binary(varargin)
            this.setGenerics(varargin);
            this.clk=eda.internal.component.ClockPort;
            this.rst=eda.internal.component.ResetPort;
            this.gray_in=eda.internal.component.Inport('FiType',this.generic.DATAWIDTH);
            this.binary_out=eda.internal.component.Outport('FiType',this.generic.DATAWIDTH);
        end

    end

end


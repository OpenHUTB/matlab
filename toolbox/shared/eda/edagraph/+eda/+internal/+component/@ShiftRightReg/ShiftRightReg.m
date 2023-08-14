classdef(ConstructOnLoad=true)ShiftRightReg<eda.internal.component.WhiteBox








    properties
clk
reset
shift
load
input
output

        generic=generics('DATA_WIDTH','integer','8');


    end


    methods
        function this=ShiftRightReg(varargin)
            this.setGenerics(varargin);
            this.clk=eda.internal.component.ClockPort;
            this.reset=eda.internal.component.ResetPort;
            this.shift=eda.internal.component.Inport('FiType','boolean');
            this.load=eda.internal.component.Inport('FiType','boolean');
            this.input=eda.internal.component.Inport('FiType',this.generic.DATA_WIDTH);
            this.output=eda.internal.component.Outport('FiType',this.generic.DATA_WIDTH);
        end
    end


end


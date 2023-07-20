classdef(ConstructOnLoad)MuxReg<eda.internal.component.WhiteBox







    properties
clk
reset
selIn1
in1
in2
output

        generic=generics('DATA_WIDTH','integer','8');
    end

    methods
        function this=MuxReg(varargin)
            this.setGenerics(varargin);
            this.clk=eda.internal.component.ClockPort;
            this.reset=eda.internal.component.ResetPort;
            this.selIn1=eda.internal.component.Inport('FiType','boolean');
            this.in1=eda.internal.component.Inport('FiType',this.generic.DATA_WIDTH);
            this.in2=eda.internal.component.Inport('FiType',this.generic.DATA_WIDTH);
            this.output=eda.internal.component.Outport('FiType',this.generic.DATA_WIDTH);
            this.flatten=false;
        end
    end

end


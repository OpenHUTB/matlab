classdef(ConstructOnLoad)Counter<eda.internal.component.WhiteBox



    properties
clk
rst
enb
cnt

        generic=generics('CNTWIDTH','integer','10')
    end

    methods
        function this=Counter(varargin)
            this.flatten=false;
            this.setGenerics(varargin);
            this.clk=eda.internal.component.ClockPort;
            this.rst=eda.internal.component.ResetPort;
            this.enb=eda.internal.component.Inport('FiType','boolean');
            this.cnt=eda.internal.component.Outport('FiType',this.generic.CNTWIDTH);
        end
    end

end


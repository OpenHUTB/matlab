classdef(ConstructOnLoad)DPRAM<eda.internal.component.WhiteBox



    properties
clkA
enbA
wr_dinA
wr_addrA
wr_enA
clkB
enbB
rd_addrB
rd_doutB

        generic=generics('DATAWIDTH','integer','8',...
        'ADDRWIDTH','integer','8');

    end

    methods
        function this=DPRAM(varargin)
            this.flatten=false;
            this.setGenerics(varargin);
            this.clkA=eda.internal.component.ClockPort;
            this.enbA=eda.internal.component.Inport('FiType','boolean');
            this.wr_enA=eda.internal.component.Inport('FiType','boolean');
            this.wr_dinA=eda.internal.component.Inport('FiType',this.generic.DATAWIDTH);
            this.wr_addrA=eda.internal.component.Inport('FiType',this.generic.ADDRWIDTH);
            this.clkB=eda.internal.component.ClockPort;
            this.enbB=eda.internal.component.Inport('FiType','boolean');
            this.rd_addrB=eda.internal.component.Inport('FiType',this.generic.ADDRWIDTH);
            this.rd_doutB=eda.internal.component.Outport('FiType',this.generic.DATAWIDTH);
        end
    end

end


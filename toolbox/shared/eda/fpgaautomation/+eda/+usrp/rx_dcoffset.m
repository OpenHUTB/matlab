


classdef(ConstructOnLoad=true)rx_dcoffset<eda.internal.component.BlackBox



    properties
clk
rst
set_stb
set_addr
set_data
adc_in
adc_out
    end

    methods
        function this=rx_dcoffset(varargin)
            this.addprop('generic');
            this.generic=generics('WIDTH','integer','14',...
            'ADDR','integer','166');
            this.setGenerics(varargin);
            this.clk=eda.internal.component.ClockPort;
            this.rst=eda.internal.component.ResetPort;
            this.set_stb=eda.internal.component.Inport('FiType','boolean');
            this.set_addr=eda.internal.component.Inport('FiType','ufix8');
            this.set_data=eda.internal.component.Inport('FiType','ufix32');
            this.adc_in=eda.internal.component.Inport('FiType',['ufix',this.generic.WIDTH.instance_Value]);
            this.adc_out=eda.internal.component.Outport('FiType',['ufix',this.generic.WIDTH.instance_Value]);

            this.addprop('NoHDLFiles');
        end

    end

end


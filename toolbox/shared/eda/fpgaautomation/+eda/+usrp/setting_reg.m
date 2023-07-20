


classdef(ConstructOnLoad=true)setting_reg<eda.internal.component.BlackBox



    properties
clk
rst
strobe
addr
in
out
changed

    end

    methods
        function this=setting_reg(varargin)
            this.addprop('generic');
            this.generic=generics('my_addr','integer','8');
            this.setGenerics(varargin)
            this.clk=eda.internal.component.ClockPort;
            this.rst=eda.internal.component.ResetPort;
            this.strobe=eda.internal.component.Inport('FiType','boolean');
            this.addr=eda.internal.component.Inport('FiType','ufix8');
            this.in=eda.internal.component.Inport('FiType','ufix32');
            this.out=eda.internal.component.Outport('FiType','ufix32');
            this.changed=eda.internal.component.Outport('FiType','boolean');
            this.addprop('NoHDLFiles');

        end
    end

end


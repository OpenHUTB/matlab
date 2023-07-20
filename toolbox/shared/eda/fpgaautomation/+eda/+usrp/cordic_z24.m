


classdef(ConstructOnLoad=true)cordic_z24<eda.internal.component.BlackBox



    properties
clock
reset
enable
xi
yi
zi
xo
yo
zo
    end

    methods
        function this=cordic_z24(varargin)
            this.addprop('generic');
            this.generic=generics('bitwidth','integer','24');
            this.setGenerics(varargin);
            this.clock=eda.internal.component.ClockPort;
            this.reset=eda.internal.component.ResetPort;
            this.enable=eda.internal.component.ClockEnablePort;
            this.xi=eda.internal.component.Inport('FiType',['ufix',this.generic.bitwidth.instance_Value]);
            this.yi=eda.internal.component.Inport('FiType',['ufix',this.generic.bitwidth.instance_Value]);
            this.xo=eda.internal.component.Outport('FiType',['ufix',this.generic.bitwidth.instance_Value]);
            this.yo=eda.internal.component.Outport('FiType',['ufix',this.generic.bitwidth.instance_Value]);
            this.zi=eda.internal.component.Inport('FiType','ufix24');
            this.zo=eda.internal.component.Outport('FiType','ufix24');

            this.addprop('NoHDLFiles');
        end

    end

end


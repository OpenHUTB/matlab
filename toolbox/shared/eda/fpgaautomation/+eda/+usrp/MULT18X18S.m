


classdef(ConstructOnLoad=true)MULT18X18S<eda.internal.component.BlackBox



    properties
C
R
CE
A
B
P
    end

    methods
        function this=MULT18X18S(varargin)
            this.C=eda.internal.component.ClockPort;
            this.R=eda.internal.component.ResetPort;
            this.CE=eda.internal.component.ClockEnablePort;
            this.A=eda.internal.component.Inport('FiType','sfix18');
            this.B=eda.internal.component.Inport('FiType','sfix18');
            this.P=eda.internal.component.Outport('FiType','sfix36');
            this.addprop('NoHDLFiles');
        end

    end

end


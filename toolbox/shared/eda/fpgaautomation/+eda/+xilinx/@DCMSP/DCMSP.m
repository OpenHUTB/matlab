classdef(ConstructOnLoad=true)DCMSP<eda.internal.component.BlackBox








    properties

CLKIN
RST
CLKFB
CLK0
CLK2X
CLKDIV
CLKFX
LOCKED



    end

    properties(SetAccess=protected)
compDeclNotNeeded
wrapperFileNotNeeded
NoHDLFiles
    end

    methods
        function this=DCMSP(varargin)
            this.UniqueName='DCM_SP';
            this.CLKIN=eda.internal.component.ClockPort;
            this.RST=eda.internal.component.ResetPort;
            this.CLKFB=eda.internal.component.Inport('FiType','boolean');
            this.CLK0=eda.internal.component.Outport('FiType','boolean');
            this.CLK2X=eda.internal.component.Outport('FiType','boolean');
            this.CLKDIV=eda.internal.component.Outport('FiType','boolean');
            this.CLKFX=eda.internal.component.Outport('FiType','boolean');
            this.LOCKED=eda.internal.component.Outport('FiType','boolean');





        end
    end

end

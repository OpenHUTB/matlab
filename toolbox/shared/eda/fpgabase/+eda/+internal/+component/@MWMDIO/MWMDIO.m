


classdef(ConstructOnLoad)MWMDIO<eda.internal.component.BlackBox



    properties

pClk
pReset
pAddr
pSel
pEnable
pWrite
pRdata
pWdata


mdc
mdio





clk
reset


CopyHDLFiles
    end

    methods
        function this=MWMDIO(varargin)

            this.setGenerics(varargin);

            this.pClk=eda.internal.component.ClockPort;
            this.pReset=eda.internal.component.ResetPort;
            this.pAddr=eda.internal.component.Inport('FiType','std32');
            this.pSel=eda.internal.component.Inport('FiType','boolean');
            this.pEnable=eda.internal.component.Inport('FiType','boolean');
            this.pWrite=eda.internal.component.Inport('FiType','boolean');
            this.pWdata=eda.internal.component.Inport('FiType','std32');
            this.pRdata=eda.internal.component.Outport('FiType','std32');

            this.clk=eda.internal.component.ClockPort;
            this.reset=eda.internal.component.ResetPort;

            this.mdc=eda.internal.component.Outport('FiType','boolean');
            this.mdio=eda.internal.component.InOutport('FiType','boolean');

            this.HDLFileDir={fullfile(matlabroot,'toolbox','shared','eda','fpgabase',...
            '+eda','+internal','+component','@MWMDIO')};
            this.HDLFiles={'MWMDIO.vhd'};

        end
    end

end


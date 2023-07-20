
classdef(ConstructOnLoad)MWAPBSPI<eda.internal.component.BlackBox


    properties

pClk
pResetn
pSel
pEnable
pReady
pAddr
pWrite
pRdata
pWdata
pSlvErr

status

SCK
CS_N
MOSI
MISO




CopyHDLFiles


    end

    methods
        function this=MWAPBSPI(varargin)
            this.setGenerics(varargin);
            this.pClk=eda.internal.component.ClockPort;
            this.pResetn=eda.internal.component.ResetPort;
            this.pSel=eda.internal.component.Inport('FiType','boolean');
            this.pEnable=eda.internal.component.Inport('FiType','boolean');
            this.pReady=eda.internal.component.Outport('FiType','boolean');
            this.pAddr=eda.internal.component.Inport('FiType','std32');
            this.pWrite=eda.internal.component.Inport('FiType','boolean');
            this.pWdata=eda.internal.component.Inport('FiType','std32');
            this.pRdata=eda.internal.component.Outport('FiType','std32');
            this.pSlvErr=eda.internal.component.Outport('FiType','boolean');

            this.status=eda.internal.component.Outport('FiType','boolean');

            this.SCK=eda.internal.component.Outport('FiType','boolean');
            this.CS_N=eda.internal.component.Outport('FiType','boolean');
            this.MOSI=eda.internal.component.Outport('FiType','boolean');
            this.MISO=eda.internal.component.Inport('FiType','boolean');




            this.HDLFileDir={fullfile(matlabroot,'toolbox','shared','eda','fpgabase',...
            '+eda','+internal','+component','@MWAPBSPI')};
            this.HDLFiles={'cmd_proc_pkg.vhd',...
            'spi_master.vhd',...
            'MWAPBSPI.vhd'};
        end
    end

end


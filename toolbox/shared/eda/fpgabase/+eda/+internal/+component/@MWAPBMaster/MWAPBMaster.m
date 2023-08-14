


classdef(ConstructOnLoad)MWAPBMaster<eda.internal.component.BlackBox



    properties

pClk
pReset
pAddr
pSel
pEnable
pWrite
pRdata
pReady
pWdata
pSlvErr
pStrb

cmd
cmdVld
cmdEOP
APBRdy

status
statusVld
statusEOP
txsRdy


CopyHDLFiles

    end

    methods
        function this=MWAPBMaster(varargin)

            this.setGenerics(varargin);

            this.pClk=eda.internal.component.ClockPort;
            this.pReset=eda.internal.component.ResetPort;
            this.pAddr=eda.internal.component.Outport('FiType','std32');
            this.pSel=eda.internal.component.Outport('FiType','std16');
            this.pEnable=eda.internal.component.Outport('FiType','boolean');
            this.pWrite=eda.internal.component.Outport('FiType','boolean');
            this.pWdata=eda.internal.component.Outport('FiType','std32');
            this.pRdata=eda.internal.component.Inport('FiType','std32');
            this.pReady=eda.internal.component.Inport('FiType','boolean');
            this.pSlvErr=eda.internal.component.Inport('FiType','boolean');
            this.pStrb=eda.internal.component.Outport('FiType','std4');

            this.cmd=eda.internal.component.Inport('FiType','std8');
            this.cmdVld=eda.internal.component.Inport('FiType','boolean');
            this.cmdEOP=eda.internal.component.Inport('FiType','boolean');
            this.APBRdy=eda.internal.component.Outport('FiType','boolean');
            this.status=eda.internal.component.Outport('FiType','std8');
            this.statusVld=eda.internal.component.Outport('FiType','boolean');
            this.statusEOP=eda.internal.component.Outport('FiType','boolean');
            this.txsRdy=eda.internal.component.Inport('FiType','boolean');

            this.HDLFileDir={fullfile(matlabroot,'toolbox','shared','eda','fpgabase',...
            '+eda','+internal','+component','@MWAPBMaster')};
            this.HDLFiles={'MWAPBMaster.vhd'};

        end
    end

end


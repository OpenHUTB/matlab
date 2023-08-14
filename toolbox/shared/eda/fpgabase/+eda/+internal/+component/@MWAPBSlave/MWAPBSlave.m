


classdef(ConstructOnLoad)MWAPBSlave<eda.internal.component.BlackBox



    properties

pClk
pResetn
pAddr
pSel
pEnable
pWrite
pRdata
pReady
pWdata
pSlvErr
pStrb


status
clearErr


slv_rxdata
slv_rxvld
slv_txdata
slv_txvld
slv_txrdy
slv_rxEOP
slv_txEOP
slv_err


CopyHDLFiles

        generic=generics('SLV_DATA_WIDTH','integer','8',...
        'SLV_BASEADDR','std8','"00000010"');

    end

    methods
        function this=MWAPBSlave(varargin)

            this.setGenerics(varargin);

            this.pClk=eda.internal.component.ClockPort;
            this.pResetn=eda.internal.component.ResetPort;
            this.pAddr=eda.internal.component.Inport('FiType','std32');
            this.pSel=eda.internal.component.Inport('FiType','boolean');
            this.pEnable=eda.internal.component.Inport('FiType','boolean');
            this.pWrite=eda.internal.component.Inport('FiType','boolean');
            this.pWdata=eda.internal.component.Inport('FiType','std32');
            this.pRdata=eda.internal.component.Outport('FiType','std32');
            this.pReady=eda.internal.component.Outport('FiType','boolean');
            this.pSlvErr=eda.internal.component.Outport('FiType','boolean');
            this.pStrb=eda.internal.component.Inport('FiType','std4');

            this.status=eda.internal.component.Outport('FiType','boolean');
            this.clearErr=eda.internal.component.Outport('FiType','boolean');

            this.slv_rxdata=eda.internal.component.Inport('FiType',this.generic.SLV_DATA_WIDTH);
            this.slv_rxvld=eda.internal.component.Inport('FiType','boolean');
            this.slv_txdata=eda.internal.component.Outport('FiType',this.generic.SLV_DATA_WIDTH);
            this.slv_txvld=eda.internal.component.Outport('FiType','boolean');
            this.slv_txrdy=eda.internal.component.Inport('FiType','boolean');
            this.slv_rxEOP=eda.internal.component.Inport('FiType','boolean');
            this.slv_txEOP=eda.internal.component.Inport('FiType','boolean');
            this.slv_err=eda.internal.component.Inport('FiType','boolean');


            this.HDLFileDir={fullfile(matlabroot,'toolbox','shared','eda','fpgabase',...
            '+eda','+internal','+component','@MWAPBSlave')};
            this.HDLFiles={'apbSlv_pkg.vhd',...
            'MWAPBSlave_fifo.vhd',...
            'MWAPBSlave.vhd'};

        end
    end

end


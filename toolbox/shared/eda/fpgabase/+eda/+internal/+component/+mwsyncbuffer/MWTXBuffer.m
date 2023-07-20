


classdef(ConstructOnLoad)MWTXBuffer<eda.internal.component.BlackBox



    properties

txclk
txclk_en
txreset

forceTxEOP
bufferStatus
clearStatus

chif_reset
chif_txclk
chif_txeop
chif_txdata
chif_txvld
chif_txrdy

TxData
TxDataValid
TxReady
TxEOP
TxDataLength

NoHDLFiles
        generic=generics('BUFFERADDRWIDTH','integer','12',...
        'MAXPKTLEN','integer','1467');

CopyHDLFiles

    end

    methods
        function this=MWTXBuffer(varargin)
            this.setGenerics(varargin);
            this.chif_txclk=eda.internal.component.ClockPort;
            this.chif_reset=eda.internal.component.ResetPort;
            this.txclk=eda.internal.component.ClockPort;
            this.txreset=eda.internal.component.Outport('FiType','boolean');
            this.forceTxEOP=eda.internal.component.Inport('FiType','boolean');
            this.bufferStatus=eda.internal.component.Outport('FiType','std2');
            this.clearStatus=eda.internal.component.Inport('FiType','boolean');
            this.TxData=eda.internal.component.Outport('FiType','std8');
            this.TxDataValid=eda.internal.component.Outport('FiType','boolean');
            this.TxEOP=eda.internal.component.Outport('FiType','boolean');
            this.TxReady=eda.internal.component.Inport('FiType','boolean');
            this.TxDataLength=eda.internal.component.Outport('FiType','std13');
            this.chif_txdata=eda.internal.component.Inport('FiType','std8');
            this.chif_txvld=eda.internal.component.Inport('FiType','boolean');
            this.chif_txeop=eda.internal.component.Inport('FiType','boolean');
            this.chif_txrdy=eda.internal.component.Outport('FiType','boolean');

            this.HDLFileDir={fullfile(matlabroot,'toolbox','shared','eda','fpgabase',...
            '+eda','+internal','+component','+mwsyncbuffer')};
            this.HDLFiles={'MWDPRAM.vhd','MWTXBuffer.vhd'};
        end
    end

end


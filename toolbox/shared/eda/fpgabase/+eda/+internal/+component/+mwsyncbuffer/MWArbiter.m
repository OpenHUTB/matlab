


classdef(ConstructOnLoad)MWArbiter<eda.internal.component.BlackBox



    properties

txclk
txclk_en
txreset

status
statusvld
statuseop
statuslen
statustx
data
datavld
dataeop
datalen
datatx

TxData
TxDataValid
TxReady
TxEOP
TxDataLength
TxStatus

NoHDLFiles
CopyHDLFiles

    end

    methods
        function this=MWArbiter(varargin)
            this.txclk=eda.internal.component.ClockPort;
            this.txreset=eda.internal.component.ResetPort;
            this.txclk_en=eda.internal.component.Inport('FiType','boolean');
            this.TxData=eda.internal.component.Outport('FiType','std8');
            this.TxDataValid=eda.internal.component.Outport('FiType','boolean');
            this.TxEOP=eda.internal.component.Outport('FiType','boolean');
            this.TxReady=eda.internal.component.Inport('FiType','boolean');
            this.TxStatus=eda.internal.component.Outport('FiType','boolean');
            this.TxDataLength=eda.internal.component.Outport('FiType','std13');
            this.status=eda.internal.component.Inport('FiType','std8');
            this.statusvld=eda.internal.component.Inport('FiType','boolean');
            this.statuseop=eda.internal.component.Inport('FiType','boolean');
            this.statuslen=eda.internal.component.Inport('FiType','std13');
            this.statustx=eda.internal.component.Outport('FiType','boolean');
            this.data=eda.internal.component.Inport('FiType','std8');
            this.datavld=eda.internal.component.Inport('FiType','boolean');
            this.dataeop=eda.internal.component.Inport('FiType','boolean');
            this.datalen=eda.internal.component.Inport('FiType','std13');
            this.datatx=eda.internal.component.Outport('FiType','boolean');

            this.HDLFileDir={fullfile(matlabroot,'toolbox','shared','eda','fpgabase',...
            '+eda','+internal','+component','+mwsyncbuffer')};
            this.HDLFiles={'MWArbiter.vhd'};
        end
    end

end





classdef(ConstructOnLoad)MWRXBuffer<eda.internal.component.BlackBox



    properties
rxclk
rxclk_en
rxreset


bufferStatus


chif_reset
chif_rxclk
chif_rxdata
chif_rxvld
chif_rxeop
chif_rxrdy

RxData
RxDataValid
RxEOP
RxCRCOK
RxCRCBad

NoHDLFiles
        generic=generics('BUFFERADDRWIDTH','integer','12',...
        'OVERFLOWMARGIN','integer','0',...
        'ISSDRDATABUFFER','integer','0');

CopyHDLFiles

    end

    methods
        function this=MWRXBuffer(varargin)
            this.setGenerics(varargin);
            this.chif_rxclk=eda.internal.component.ClockPort;
            this.chif_reset=eda.internal.component.ResetPort;
            this.rxclk=eda.internal.component.ClockPort;
            this.rxreset=eda.internal.component.Outport('FiType','boolean');
            this.bufferStatus=eda.internal.component.Outport('FiType','std8');
            this.RxData=eda.internal.component.Inport('FiType','std8');
            this.RxDataValid=eda.internal.component.Inport('FiType','boolean');
            this.RxEOP=eda.internal.component.Inport('FiType','boolean');
            this.RxCRCOK=eda.internal.component.Inport('FiType','boolean');
            this.RxCRCBad=eda.internal.component.Inport('FiType','boolean');
            this.chif_rxdata=eda.internal.component.Outport('FiType','std8');
            this.chif_rxvld=eda.internal.component.Outport('FiType','boolean');
            this.chif_rxeop=eda.internal.component.Outport('FiType','boolean');
            this.chif_rxrdy=eda.internal.component.Inport('FiType','boolean');

            this.HDLFileDir={fullfile(matlabroot,'toolbox','shared','eda','fpgabase',...
            '+eda','+internal','+component','+mwsyncbuffer')};
            this.HDLFiles={'MWDPRAM.vhd','MWRXBuffer.vhd'};
        end
    end

end


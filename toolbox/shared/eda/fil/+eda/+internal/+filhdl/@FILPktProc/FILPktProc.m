



classdef FILPktProc<eda.internal.component.BlackBox


    properties
rxclk
txclk
rxclk_en
txclk_en
RxData
RxDataValid
RxEOP
RxCRCOK
RxCRCBad
RxDstPort
RxReset
TxData
TxDataValid
TxEOP
TxReady
TxReset
TxDataLength
TxSrcPort
clk
rst
dut_rst
dut_din
dut_dinvld
dut_dinrdy
simcycle
dut_dout
dut_doutvld
dut_doutrdy

        generic=generics(...
        'VERSION','std16','X"0200"',...
        'RXBUFFERADDRWIDTH','integer','12');

CopyHDLFiles
    end

    methods
        function this=FILPktProc(varargin)
            this.setGenerics(varargin);

            this.rxclk=eda.internal.component.ClockPort;
            this.txclk=eda.internal.component.ClockPort;
            this.rxclk_en=eda.internal.component.Inport('FiType','boolean');
            this.txclk_en=eda.internal.component.Inport('FiType','boolean');
            this.RxData=eda.internal.component.Inport('FiType','std8');
            this.RxDataValid=eda.internal.component.Inport('FiType','boolean');
            this.RxEOP=eda.internal.component.Inport('FiType','boolean');
            this.RxCRCOK=eda.internal.component.Inport('FiType','boolean');
            this.RxCRCBad=eda.internal.component.Inport('FiType','boolean');
            this.RxDstPort=eda.internal.component.Inport('FiType','std2');
            this.RxReset=eda.internal.component.Outport('FiType','boolean');
            this.TxData=eda.internal.component.Outport('FiType','std8');
            this.TxDataValid=eda.internal.component.Outport('FiType','boolean');
            this.TxEOP=eda.internal.component.Outport('FiType','boolean');
            this.TxReady=eda.internal.component.Inport('FiType','boolean');
            this.TxReset=eda.internal.component.Outport('FiType','boolean');
            this.TxDataLength=eda.internal.component.Outport('FiType','std13');
            this.TxSrcPort=eda.internal.component.Outport('FiType','std2');
            this.clk=eda.internal.component.ClockPort;
            this.rst=eda.internal.component.ResetPort;
            this.dut_rst=eda.internal.component.Outport('FiType','boolean');
            this.dut_din=eda.internal.component.Outport('FiType','std8');
            this.dut_dinvld=eda.internal.component.Outport('FiType','boolean');
            this.dut_dinrdy=eda.internal.component.Inport('FiType','boolean');
            this.simcycle=eda.internal.component.Outport('FiType','std16');
            this.dut_dout=eda.internal.component.Inport('FiType','std8');
            this.dut_doutvld=eda.internal.component.Inport('FiType','boolean');
            this.dut_doutrdy=eda.internal.component.Outport('FiType','boolean');

            this.HDLFileDir=fullfile(matlabroot,'toolbox','shared','eda','fil','+eda','+internal','+filhdl','@FILPktProc');
            this.HDLFiles={'MWDPRAM.vhd','FILUDPCRC.vhd','FILPktMUX.vhd','FILCmdProc.vhd','MWAsyncFIFO.vhd','FILDataProc.vhd','MWPKTBuffer.vhd','MWUDPPKTBuilder.vhd','FILPktProc.vhd'};
        end
    end
end


classdef(ConstructOnLoad)MWChIfCtrl<eda.internal.component.WhiteBox








    properties
rxdclk
txdclk
rxdrst
txdrst
dinVld
unPackDone
txRdy
rxEOP
simCycle
updateSimCycle
dutEnb
shftOutReg
rxRdy
txEOP
simMode
NOPcmd
tx_stream_en

        generic=generics('RX_DATAWIDTH','integer','8',...
        'TX_DATAWIDTH','integer','8',...
        'COUPLE_RXTX','boolean','''1''');
    end

    methods
        function this=MWChIfCtrl(varargin)
            this.setGenerics(varargin);
            this.rxdclk=eda.internal.component.ClockPort;
            this.txdclk=eda.internal.component.ClockPort;
            this.rxdrst=eda.internal.component.ResetPort;
            this.txdrst=eda.internal.component.ResetPort;
            this.dinVld=eda.internal.component.Inport('FiType','boolean');
            this.unPackDone=eda.internal.component.Inport('FiType','boolean');
            this.txRdy=eda.internal.component.Inport('FiType','boolean');
            this.rxEOP=eda.internal.component.Inport('FiType','boolean');
            this.simCycle=eda.internal.component.Inport('FiType','uint16');
            this.updateSimCycle=eda.internal.component.Outport('FiType','boolean');
            this.simMode=eda.internal.component.Inport('FiType','boolean');
            this.NOPcmd=eda.internal.component.Inport('FiType','boolean');
            this.dutEnb=eda.internal.component.Outport('FiType','boolean');
            this.shftOutReg=eda.internal.component.Outport('FiType','boolean');
            this.rxRdy=eda.internal.component.Outport('FiType','boolean');
            this.txEOP=eda.internal.component.Outport('FiType','boolean');
            this.tx_stream_en=eda.internal.component.Inport('FiType','boolean');
            this.flatten=false;
        end

        function implement(this)
            txDone=this.signal('Name','txDone','FiType','boolean');
            txCompleted=this.signal('Name','txCompleted','FiType','boolean');
            simCycle_temp=this.signal('Name','simCycle_temp','FiType','std16');
            if strcmp(this.getGenericInstanceValue(this.generic.COUPLE_RXTX),'''0''')
                rxEOP_temp='1';
                this.assign('fi(0,0,16,0)',simCycle_temp);
            else
                rxEOP_temp=this.rxEOP;
                this.assign(this.simCycle,simCycle_temp);
            end

            this.component(...
            'Name','MWChIfRXCtrl',...
            'Component',eda.internal.component.MWChIfRXCtrl('RX_DATAWIDTH',this.generic.RX_DATAWIDTH,...
            'TX_DATAWIDTH',this.generic.TX_DATAWIDTH,...
            'COUPLE_RXTX',this.getGenericInstanceValue(this.generic.COUPLE_RXTX)),...
            'clk',this.rxdclk,...
            'reset',this.rxdrst,...
            'unPackDone',this.unPackDone,...
            'simCycle',this.simCycle,...
            'updateSimCycle',this.updateSimCycle,...
            'dutEnb',this.dutEnb,...
            'rxRdy',this.rxRdy,...
            'txCompleted',txCompleted,...
            'txDone',txDone,...
            'rxEOP',this.rxEOP,...
            'tx_stream_en',this.tx_stream_en);

            this.component(...
            'Name','MWChIfTXCtrl',...
            'Component',eda.internal.component.MWChIfTXCtrl('TX_DATAWIDTH',this.generic.TX_DATAWIDTH,...
            'RX_DATAWIDTH',this.generic.RX_DATAWIDTH,...
            'COUPLE_RXTX',this.getGenericInstanceValue(this.generic.COUPLE_RXTX)),...
            'dclk',this.txdclk,...
            'reset',this.txdrst,...
            'dinVld',this.dinVld,...
            'txRdy',this.txRdy,...
            'rxEOP',rxEOP_temp,...
            'simCycle',simCycle_temp,...
            'simMode',this.simMode,...
            'NOPcmd',this.NOPcmd,...
            'shftOutReg',this.shftOutReg,...
            'txEOP',this.txEOP,...
            'txCompleted',txCompleted,...
            'txDone',txDone);

        end
    end
end
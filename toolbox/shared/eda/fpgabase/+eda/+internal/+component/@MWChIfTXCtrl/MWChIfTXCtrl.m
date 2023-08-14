
classdef(ConstructOnLoad)MWChIfTXCtrl<eda.internal.component.WhiteBox








    properties
dclk
reset
dinVld
txRdy
rxEOP
simCycle
simMode
NOPcmd
shftOutReg
txEOP
txCompleted
txDone

        generic=generics('TX_DATAWIDTH','integer','8',...
        'RX_DATAWIDTH','integer','8',...
        'COUPLE_RXTX','boolean','''1''');

    end

    methods
        function this=MWChIfTXCtrl(varargin)
            this.setGenerics(varargin);
            this.dclk=eda.internal.component.ClockPort;
            this.reset=eda.internal.component.ResetPort;
            this.dinVld=eda.internal.component.Inport('FiType','boolean');
            this.txRdy=eda.internal.component.Inport('FiType','boolean');
            this.rxEOP=eda.internal.component.Inport('FiType','boolean');
            this.simCycle=eda.internal.component.Inport('FiType','uint16');
            this.simMode=eda.internal.component.Inport('FiType','boolean');
            this.NOPcmd=eda.internal.component.Inport('FiType','boolean');
            this.shftOutReg=eda.internal.component.Outport('FiType','boolean');
            this.txEOP=eda.internal.component.Outport('FiType','boolean');
            this.txCompleted=eda.internal.component.Outport('FiType','boolean');
            this.txDone=eda.internal.component.Outport('FiType','boolean');
            this.flatten=false;
        end
    end
end
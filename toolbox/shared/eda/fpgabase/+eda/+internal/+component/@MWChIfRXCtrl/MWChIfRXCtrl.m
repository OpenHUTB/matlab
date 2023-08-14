
classdef(ConstructOnLoad)MWChIfRXCtrl<eda.internal.component.WhiteBox








    properties
clk
reset
unPackDone
simCycle
dutEnb
rxRdy
txCompleted
txDone
updateSimCycle
rxEOP
tx_stream_en

        generic=generics('RX_DATAWIDTH','integer','8',...
        'TX_DATAWIDTH','integer','8',...
        'COUPLE_RXTX','boolean','''1''');

    end

    methods
        function this=MWChIfRXCtrl(varargin)
            this.setGenerics(varargin);
            this.clk=eda.internal.component.ClockPort;
            this.reset=eda.internal.component.ResetPort;
            this.unPackDone=eda.internal.component.Inport('FiType','boolean');
            this.simCycle=eda.internal.component.Inport('FiType','uint16');
            this.dutEnb=eda.internal.component.Outport('FiType','boolean');
            this.rxRdy=eda.internal.component.Outport('FiType','boolean');
            this.txCompleted=eda.internal.component.Inport('FiType','boolean');
            this.txDone=eda.internal.component.Inport('FiType','boolean');
            this.rxEOP=eda.internal.component.Inport('FiType','boolean');
            this.updateSimCycle=eda.internal.component.Outport('FiType','boolean');
            this.tx_stream_en=eda.internal.component.Inport('FiType','boolean');
            this.flatten=false;
        end
    end
end



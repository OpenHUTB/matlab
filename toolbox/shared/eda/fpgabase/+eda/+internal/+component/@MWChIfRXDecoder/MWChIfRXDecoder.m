classdef(ConstructOnLoad)MWChIfRXDecoder<eda.internal.component.WhiteBox










    properties
clk
rxdrst
cmdrst

rxData
rxVld
rxRdy
rxEOP

rxEOPAck
simCycle
updateSimCycle
simMode
txDataLength
unPackDone
payLoad
payLoadVld

rxcclk
rxCmd
rxCmdVld
rxCmdRdy
rxCmdEOP

cmd
cmdVld
cmdRdy
cmdEOP

coupleRxTx

    end

    methods
        function this=MWChIfRXDecoder
            this.clk=eda.internal.component.ClockPort;
            this.rxdrst=eda.internal.component.ResetPort;
            this.cmdrst=eda.internal.component.ResetPort;

            this.rxData=eda.internal.component.Inport('FiType','std8');
            this.rxVld=eda.internal.component.Inport('FiType','boolean');
            this.rxRdy=eda.internal.component.Inport('FiType','boolean');
            this.rxEOP=eda.internal.component.Inport('FiType','boolean');

            this.rxEOPAck=eda.internal.component.Outport('FiType','boolean');
            this.simMode=eda.internal.component.Outport('FiType','boolean');
            this.simCycle=eda.internal.component.Outport('FiType','std16');
            this.updateSimCycle=eda.internal.component.Inport('FiType','boolean');
            this.txDataLength=eda.internal.component.Outport('FiType','std16');
            this.unPackDone=eda.internal.component.Inport('FiType','boolean');
            this.payLoad=eda.internal.component.Outport('FiType','std8');
            this.payLoadVld=eda.internal.component.Outport('FiType','boolean');

            this.rxcclk=eda.internal.component.ClockPort;
            this.rxCmd=eda.internal.component.Inport('FiType','std8');
            this.rxCmdVld=eda.internal.component.Inport('FiType','boolean');
            this.rxCmdRdy=eda.internal.component.Outport('FiType','boolean');
            this.rxCmdEOP=eda.internal.component.Inport('FiType','boolean');

            this.cmd=eda.internal.component.Outport('FiType','std8');
            this.cmdVld=eda.internal.component.Outport('FiType','boolean');
            this.cmdEOP=eda.internal.component.Outport('FiType','boolean');
            this.cmdRdy=eda.internal.component.Inport('FiType','boolean');
            this.coupleRxTx=eda.internal.component.Inport('FiType','boolean');
            this.flatten=false;
        end

    end

end
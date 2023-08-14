classdef(ConstructOnLoad)MWChIfRX<eda.internal.component.WhiteBox








    properties
clk
rxdrst
cmdrst
rxData
rxVld
rxRdy
rxEOP

simCycle
updateSimCycle
simMode
rxEOPAck
txDataLength
dout
unPackDone

rxcclk
rxCmd
rxCmdVld
rxCmdRdy
rxCmdEOP
cmd
cmdVld
cmdRdy
cmdEOP

        generic=generics('OUTPUT_DATAWIDTH','integer','8',...
        'COUPLE_RXTX','boolean','''1''');
    end

    methods
        function this=MWChIfRX(varargin)
            this.setGenerics(varargin);
            this.clk=eda.internal.component.ClockPort;
            this.rxdrst=eda.internal.component.ResetPort;
            this.cmdrst=eda.internal.component.ResetPort;
            this.rxData=eda.internal.component.Inport('FiType','std8');
            this.rxVld=eda.internal.component.Inport('FiType','boolean');
            this.rxRdy=eda.internal.component.Inport('FiType','boolean');
            this.rxEOP=eda.internal.component.Inport('FiType','boolean');
            this.simMode=eda.internal.component.Outport('FiType','boolean');
            this.rxEOPAck=eda.internal.component.Outport('FiType','boolean');
            this.txDataLength=eda.internal.component.Outport('FiType','std16');
            this.simCycle=eda.internal.component.Outport('FiType','std16');
            this.updateSimCycle=eda.internal.component.Inport('FiType','boolean');
            this.unPackDone=eda.internal.component.Outport('FiType','boolean');

            this.rxcclk=eda.internal.component.ClockPort;
            this.rxCmd=eda.internal.component.Inport('FiType','std8');
            this.rxCmdVld=eda.internal.component.Inport('FiType','boolean');
            this.rxCmdRdy=eda.internal.component.Outport('FiType','boolean');
            this.rxCmdEOP=eda.internal.component.Inport('FiType','boolean');
            this.cmd=eda.internal.component.Outport('FiType','std8');
            this.cmdVld=eda.internal.component.Outport('FiType','boolean');
            this.cmdEOP=eda.internal.component.Outport('FiType','boolean');
            this.cmdRdy=eda.internal.component.Inport('FiType','boolean');

            dataWidth=this.getGenericInstanceValue(this.generic.OUTPUT_DATAWIDTH);
            if dataWidth>0
                this.dout=eda.internal.component.Outport('FiType',this.generic.OUTPUT_DATAWIDTH);
            else
                this.dout=eda.internal.component.Outport('FiType','boolean');
            end
            this.flatten=false;
        end

        function implement(this)

            dataWidth=this.getGenericInstanceValue(this.generic.OUTPUT_DATAWIDTH);

            if dataWidth>0
                payLoad=this.signal('Name','payLoad','FiType','std8');
                payLoadVld=this.signal('Name','payLoadVld','FiType','boolean');
                unPktDone=this.signal('Name','unPktDone','FiType','boolean');
            else
                payLoad='OPEN';
                payLoadVld='OPEN';
                unPktDone='HIGH';
            end

            if strcmp(this.getGenericInstanceValue(this.generic.COUPLE_RXTX),'''0''')
                rxEOP_temp='0';
            else
                rxEOP_temp=this.rxEOP;
            end

            coupleS=eval(this.getGenericInstanceValue(this.generic.COUPLE_RXTX));

            this.component(...
            'Name','MWChIfRXDecoder',...
            'Component',eda.internal.component.MWChIfRXDecoder,...
            'clk',this.clk,...
            'rxdrst',this.rxdrst,...
            'cmdrst',this.cmdrst,...
            'rxData',this.rxData,...
            'rxVld',this.rxVld,...
            'rxRdy',this.rxRdy,...
            'rxEOP',rxEOP_temp,...
            'simMode',this.simMode,...
            'txDataLength',this.txDataLength,...
            'rxEOPAck',this.rxEOPAck,...
            'simCycle',this.simCycle,...
            'updateSimCycle',this.updateSimCycle,...
            'unPackDone',unPktDone,...
            'payLoad',payLoad,...
            'payLoadVld',payLoadVld,...
            'rxcclk',this.rxcclk,...
            'rxCmd',this.rxCmd,...
            'rxCmdVld',this.rxCmdVld,...
            'rxCmdRdy',this.rxCmdRdy,...
            'rxCmdEOP',this.rxCmdEOP,...
            'cmd',this.cmd,...
            'cmdVld',this.cmdVld,...
            'cmdRdy',this.cmdRdy,...
            'cmdEOP',this.cmdEOP,...
            'coupleRxTx',coupleS);

            if dataWidth>0
                this.component(...
                'Name','MWChIfRXUnpack',...
                'Component',eda.internal.component.MWChIfRXUnpack('OUTPUT_DATAWIDTH',this.generic.OUTPUT_DATAWIDTH),...
                'clk',this.clk,...
                'reset',this.rxdrst,...
                'rxData',payLoad,...
                'rxVld',payLoadVld,...
                'unPackDone',unPktDone,...
                'dout',this.dout);

                this.assign(unPktDone,this.unPackDone);
            else
                unPktDone=this.signal('Name','unPktDone','FiType','boolean');
                this.assign('fi(1, 0, 1, 0)',unPktDone);
                this.assign(unPktDone,this.unPackDone);
                payLoad=this.signal('Name','payLoad','FiType','boolean');
                this.assign('fi(0, 0, 1, 0)',payLoad);
                this.assign(payLoad,this.dout);
            end

        end
    end
end
classdef(ConstructOnLoad)MWChIfRXUnpack<eda.internal.component.WhiteBox







    properties
clk
reset
rxData
rxVld
unPackDone
dout

        generic=generics('OUTPUT_DATAWIDTH','integer','8');

    end

    methods
        function this=MWChIfRXUnpack(varargin)
            this.setGenerics(varargin);
            this.clk=eda.internal.component.ClockPort;
            this.reset=eda.internal.component.ResetPort;
            this.rxData=eda.internal.component.Inport('FiType','std8');
            this.rxVld=eda.internal.component.Inport('FiType','boolean');
            this.unPackDone=eda.internal.component.Outport('FiType','boolean');
            this.dout=eda.internal.component.Outport('FiType',this.generic.OUTPUT_DATAWIDTH);
            this.flatten=false;
        end

        function implement(this)
            dataWidth=this.getGenericInstanceValue(this.generic.OUTPUT_DATAWIDTH);
            ENB_WIDTH=floor(dataWidth/8)+(mod(dataWidth,8)~=0);
            enbWidthType=['std',num2str(ENB_WIDTH)];

            dout_total=this.signal('Name','dout_total','FiType',['std',num2str(dataWidth)]);


            for i=1:ENB_WIDTH
                dout_(i)=this.signal('Name',['dout_',num2str(i-1)],'FiType','std8');%#ok<*AGROW,PROP>
            end


            doutStr='';
            for i=ENB_WIDTH:-1:1
                doutStr=[dout_(i).Name,',',doutStr];
            end

            doutStr(end)='';


            this.assign(['bitconcat(',doutStr,')'],dout_total);
            this.assign(dout_total,this.dout);

            if dataWidth>8
                unPktDone=this.signal('Name','unPktDone','FiType','boolean');
                enbReg=this.signal('Name','enbReg','FiType',enbWidthType);
                mask=this.signal('Name','mask','FiType',enbWidthType);
                enbReg_0=this.signal('Name','enbReg_0','FiType','boolean');
                enb=this.signal('Name','enb','FiType',enbWidthType);
                this.assign(unPktDone,this.unPackDone);
                this.assign(['bitreplicate(this.rxVld, ',num2str(ENB_WIDTH),')'],mask);
                this.assign('bitand(enbReg, mask)',enb);
                this.assign('bitsliceget(enbReg, 0)',enbReg_0);
                this.assign('bitand(enbReg_0, rxVld)',unPktDone);
                this.component(...
                'Name','MWRotateRight',...
                'Component',eda.internal.component.RotateRightReg('DATA_WIDTH',num2str(ENB_WIDTH)),...
                'clk',this.clk,...
                'reset',this.reset,...
                'shift',this.rxVld,...
                'load','LOW',...
                'input','LOW',...
                'output',enbReg);
                for i=1:ENB_WIDTH
                    enbBit(i)=this.signal('Name',['enbBit_',num2str(ENB_WIDTH-i)],'FiType','boolean');
                    this.assign(['bitsliceget(enb, ',num2str(ENB_WIDTH-i),')'],enbBit(i));
                    this.component(...
                    'Name','MWMuxReg',...
                    'Component',eda.internal.component.MuxReg('DATA_WIDTH','8'),...
                    'clk',this.clk,...
                    'reset',this.reset,...
                    'selIn1',enbBit(i),...
                    'in1',this.rxData,...
                    'in2',dout_(ENB_WIDTH-i+1),...
                    'output',dout_(ENB_WIDTH-i+1));
                end
            else
                unPktDone=this.signal('Name','unPktDone','FiType','boolean');
                this.assign(this.rxVld,unPktDone);
                this.assign(unPktDone,this.unPackDone);
                this.component(...
                'Name','MWMuxReg',...
                'Component',eda.internal.component.MuxReg('DATA_WIDTH','8'),...
                'clk',this.clk,...
                'reset',this.reset,...
                'selIn1',this.rxVld,...
                'in1',this.rxData,...
                'in2',dout_(ENB_WIDTH-i+1),...
                'output',dout_(ENB_WIDTH-i+1));
            end


        end
    end

end


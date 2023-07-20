


classdef mwfil_chiftop<eda.internal.component.MWCore



    properties
clk
reset
din
din_valid
din_ready
dout
dout_valid
dout_ready
simcycle

buildInfo
commprops
bitwidth
    end

    methods
        function this=mwfil_chiftop(BuildInfo,BitWidth)
            if nargin<2
                BitWidth=128;
            end
            this.bitwidth=BitWidth;
            this.buildInfo=BuildInfo;
            this.clk=eda.internal.component.ClockPort;
            this.reset=eda.internal.component.ResetPort;

            this.din=eda.internal.component.Inport('FiType',['std',num2str(BitWidth)]);
            this.din_valid=eda.internal.component.Inport('FiType','boolean');
            this.din_ready=eda.internal.component.Outport('FiType','boolean');

            this.dout=eda.internal.component.Outport('FiType',['std',num2str(BitWidth)]);
            this.dout_valid=eda.internal.component.Outport('FiType','boolean');
            this.dout_ready=eda.internal.component.Inport('FiType','boolean');

            this.simcycle=eda.internal.component.Inport('FiType','std16');


            this.flatten=false;
        end

        function implement(this)

            [inPutDataWidth,outPutDataWidth]=getIOBitWidth(this,this.buildInfo);
            inPutDataWidth=l_getIntegerMultipleOf(inPutDataWidth,this.bitwidth);
            outPutDataWidth=l_getIntegerMultipleOf(outPutDataWidth,this.bitwidth);
            inWord=inPutDataWidth/this.bitwidth;
            outWord=outPutDataWidth/this.bitwidth;

            dutDin=this.signal('Name','dut_din','FiType',['std',num2str(inPutDataWidth)]);
            dutDout=this.signal('Name','dut_dout','FiType',['std',num2str(outPutDataWidth)]);
            dutEnb=this.signal('Name','dut_clkenb','FiType','boolean');

            hasenable=~isempty(this.buildInfo.getClockEnablePortName);
            this.component(...
            'Name','mwfil_chifcore',...
            'Component',eda.internal.filhdl.mwfil_chifcore(inWord,outWord,this.bitwidth,hasenable),...
            'clk',this.clk,...
            'reset',this.reset,...
            'dut_enable',dutEnb,...
            'dut_din',dutDin,...
            'dut_dout',dutDout,...
            'din',this.din,...
            'dout',this.dout,...
            'din_valid',this.din_valid,...
            'din_ready',this.din_ready,...
            'dout_valid',this.dout_valid,...
            'dout_ready',this.dout_ready,...
            'simcycle',this.simcycle);

            this.component(...
            'UniqueName',[this.buildInfo.DUTName,'_wrapper'],...
            'InstName','dut',...
            'Component',eda.internal.filhdl.mwfil_dutwrapper(this.buildInfo,inPutDataWidth,outPutDataWidth),...
            'clk',this.clk,...
            'reset',this.reset,...
            'enb',dutEnb,...
            'din',dutDin,...
            'dout',dutDout);



        end

    end
end


function r=l_getIntegerMultipleOf(a,b)
    r=ceil(a/b)*b;
end

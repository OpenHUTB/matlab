classdef(ConstructOnLoad)SYNCFIFO<eda.internal.component.WhiteBox



    properties
clk
rst
din
rden
wren
dout
full
empty

        generic=generics(...
        'DATAWIDTH','integer','8',...
        'ADDRWIDTH','integer','8');

    end

    methods
        function this=SYNCFIFO(varargin)
            this.flatten=false;
            this.setGenerics(varargin);

            this.clk=eda.internal.component.ClockPort;
            this.rst=eda.internal.component.ResetPort;
            this.din=eda.internal.component.Inport('FiType',this.generic.DATAWIDTH);
            this.rden=eda.internal.component.Inport('FiType','boolean');
            this.wren=eda.internal.component.Inport('FiType','boolean');
            this.dout=eda.internal.component.Outport('FiType',this.generic.DATAWIDTH);
            this.empty=eda.internal.component.Outport('FiType','boolean');
            this.full=eda.internal.component.Outport('FiType','boolean');

        end

        function implement(this)
            cntWidth=this.getGenericInstanceValue(this.generic.ADDRWIDTH);

            wr_addr=this.signal('Name','wr_addr','FiType',this.generic.ADDRWIDTH);
            rd_addr=this.signal('Name','rd_addr','FiType',this.generic.ADDRWIDTH);

            ramOutput=this.signal('Name','ramOutput','FiType',this.generic.DATAWIDTH);
            rden_reg=this.signal('Name','rdenreg','FiType','boolean');

            this.component(...
            'Name','DPRAM',...
            'Component',eda.internal.component.DPRAM('DATAWIDTH',this.generic.DATAWIDTH,...
            'ADDRWIDTH',this.generic.ADDRWIDTH),...
            'clkA',this.clk,...
            'clkB',this.clk,...
            'wr_enA',this.wren,...
            'wr_dinA',this.din,...
            'wr_addrA',wr_addr,...
            'enbA','1',...
            'enbB','1',...
            'rd_addrB',rd_addr,...
            'rd_doutB',ramOutput);

            this.component(...
            'Name','Counter',...
            'Component',eda.internal.component.Counter('CNTWIDTH',num2str(cntWidth)),...
            'clk',this.clk,...
            'rst',this.rst,...
            'enb',this.rden,...
            'cnt',rd_addr);

            this.component(...
            'Name','Counter',...
            'Component',eda.internal.component.Counter('CNTWIDTH',num2str(cntWidth)),...
            'clk',this.clk,...
            'rst',this.rst,...
            'enb',this.wren,...
            'cnt',wr_addr);


            this.component(...
            'Name','rdenb_delay',...
            'Component',eda.internal.component.Register,...
            'clk',this.clk,...
            'reset',this.rst,...
            'din',this.rden,...
            'dout',rden_reg);


            this.component(...
            'Name','doutReg',...
            'Component',eda.internal.component.Register,...
            'clk',this.clk,...
            'reset',this.rst,...
            'clkenb',rden_reg,...
            'din',ramOutput,...
            'dout',this.dout);

            FIFOStatus=this.component(...
            'Name','FIFOStatus',...
            'UniqueName','FIFOStatus',...
            'flatten',true,...
            'DescFunc',this.SYNCFIFOStatus,...
            'Component',eda.internal.component.WhiteBox({'clk','INPUT','ClockPort',...
            'rst','INPUT','ResetPort',...
            'wr_en','INPUT','boolean',...
            'rd_en','INPUT','boolean',...
            'FullFlag','OUTPUT','boolean',...
            'EmptyFlag','OUTPUT','boolean'}),...
            'clk',this.clk,...
            'rst',this.rst,...
            'wr_en',this.wren,...
            'rd_en',this.rden,...
            'FullFlag',this.full,...
            'EmptyFlag',this.empty);

            FIFOStatus.addprop('enableCodeGen');

        end

        hdlcode=SYNCFIFOStatus(this);
    end

end


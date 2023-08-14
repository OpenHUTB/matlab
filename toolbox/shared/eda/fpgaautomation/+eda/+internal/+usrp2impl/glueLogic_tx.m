


classdef(ConstructOnLoad=true)glueLogic_tx<eda.internal.component.WhiteBox



    properties
clk
rst
run

dacmux
sample
scale
fromFilter_i
fromFilter_q
toCordic_xi
toCordic_yi
fromCordic_xo
fromCordic_yo
prod_i
prod_q
phase_inc
enbANDRate

toFilter_i
toFilter_q
mult_i
scale_i
mult_q
scale_q
phase
rate
load_rate
dac_a
dac_b

    end

    methods

        function this=glueLogic_tx
            this.clk=eda.internal.component.ClockPort;
            this.rst=eda.internal.component.ResetPort;
            this.run=eda.internal.component.Inport('FiType','boolean');

            this.sample=eda.internal.component.Inport('FiType','ufix32');
            this.scale=eda.internal.component.Inport('FiType','ufix32');
            this.fromFilter_i=eda.internal.component.Inport('FiType','ufix18');
            this.fromFilter_q=eda.internal.component.Inport('FiType','ufix18');
            this.fromCordic_xo=eda.internal.component.Inport('FiType','ufix24');
            this.fromCordic_yo=eda.internal.component.Inport('FiType','ufix24');
            this.prod_i=eda.internal.component.Inport('FiType','ufix36');
            this.prod_q=eda.internal.component.Inport('FiType','ufix36');
            this.phase_inc=eda.internal.component.Inport('FiType','ufix32');
            this.enbANDRate=eda.internal.component.Inport('FiType','ufix32');
            this.dacmux=eda.internal.component.Inport('FiType','ufix32');

            this.toFilter_i=eda.internal.component.Outport('FiType','ufix18');
            this.toFilter_q=eda.internal.component.Outport('FiType','ufix18');
            this.toCordic_xi=eda.internal.component.Outport('FiType','ufix24');
            this.toCordic_yi=eda.internal.component.Outport('FiType','ufix24');
            this.mult_i=eda.internal.component.Outport('FiType','ufix18');
            this.scale_i=eda.internal.component.Outport('FiType','ufix18');
            this.mult_q=eda.internal.component.Outport('FiType','ufix18');
            this.scale_q=eda.internal.component.Outport('FiType','ufix18');
            this.phase=eda.internal.component.Outport('FiType','ufix24');
            this.rate=eda.internal.component.Outport('FiType','ufix8');
            this.load_rate=eda.internal.component.Outport('FiType','boolean');
            this.dac_a=eda.internal.component.Outport('FiType','ufix16');
            this.dac_b=eda.internal.component.Outport('FiType','ufix16');

            this.flatten=false;
        end

        function hdlcode=componentBody(this)
            hdlcode=this.hdlcodeinit;
            hdlcode.arch_signals=[...
            'reg [31:0] phase_tmp;\n',...
            'reg [15:0] dac_a;\n',...
            'reg [15:0] dac_b;\n\n'];
            hdlcode.arch_body_blocks=[...
            '  always @(posedge clk) \n',...
            '    case(dacmux[15:0])\n',...
            '         0: dac_a <= prod_i[28:13];\n',...
            '         1: dac_a <= prod_q[28:13];\n',...
            '         default: dac_a <= 0;\n',...
            '    endcase // case(dacmux_a)\n\n',...
            '  always @(posedge clk)\n',...
            '    case(dacmux[31:16])\n',...
            '       0: dac_b <= prod_i[28:13];\n',...
            '       1: dac_b <= prod_q[28:13];\n',...
            '       default: dac_b <= 0;\n',...
            '    endcase // case(dacmux_b)\n\n',...
            '  always @(posedge clk)\n',...
            '    if(rst)\n',...
            '      phase_tmp <= 0;\n',...
            '    else if(~run)\n',...
            '      phase_tmp <= 0;\n',...
            '    else\n',...
            '      phase_tmp <= phase_tmp + phase_inc;\n\n',...
            '  assign      scale_i    = {{2{scale[31]}},scale[31:16]};\n',...
            '  assign      scale_q    = {{2{scale[15]}},scale[15:0]};\n',...
            '  assign      mult_i     = fromCordic_xo[23:6];\n',...
            '  assign      mult_q     = fromCordic_yo[23:6];\n',...
            '  assign      rate       = enbANDRate[7:0];\n',...
            '  assign      load_rate  = ~run;\n',...
            '  assign      toFilter_i = {sample[31:16],2''b0};\n',...
            '  assign      toFilter_q = {sample[15:0],2''b0};\n',...
            '  assign      toCordic_xi= {fromFilter_i,{6{1''b0}}};\n',...
            '  assign      toCordic_yi= {fromFilter_q,{6{1''b0}}};\n',...
            '  assign      phase      = phase_tmp[31:8];\n',...
            ];
        end

    end

end


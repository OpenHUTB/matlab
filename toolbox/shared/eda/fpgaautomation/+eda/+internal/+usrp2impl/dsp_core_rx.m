


classdef(ConstructOnLoad=true)dsp_core_rx<eda.internal.component.WhiteBox



    properties
clk
rst
set_stb
set_addr
set_data

adc_a
adc_ovf_a
adc_b
adc_ovf_b

io_rx

sample
run
strobe
debug

    end

    methods
        function this=dsp_core_rx(varargin)
            this.clk=eda.internal.component.ClockPort;
            this.rst=eda.internal.component.ResetPort;
            this.set_stb=eda.internal.component.Inport('FiType','boolean');
            this.set_addr=eda.internal.component.Inport('FiType','ufix8');
            this.set_data=eda.internal.component.Inport('FiType','ufix32');

            this.adc_a=eda.internal.component.Inport('FiType','ufix14');
            this.adc_ovf_a=eda.internal.component.Inport('FiType','boolean');
            this.adc_b=eda.internal.component.Inport('FiType','ufix14');
            this.adc_ovf_b=eda.internal.component.Inport('FiType','boolean');

            this.io_rx=eda.internal.component.Inport('FiType','ufix16');

            this.sample=eda.internal.component.Outport('FiType','ufix32');
            this.run=eda.internal.component.Inport('FiType','boolean');
            this.strobe=eda.internal.component.Outport('FiType','boolean');
            this.debug=eda.internal.component.Outport('FiType','ufix32');
        end

        function implement(this)
            phase_inc=this.signal('Name','phase_inc','FiType','ufix32');
            scale=this.signal('Name','scale','FiType','ufix32');
            enbANDRate=this.signal('Name','enbAndRate','FiType','ufix32');
            muxctrl=this.signal('Name','muxctrl','FiType','ufix32');
            gpio_ena=this.signal('Name','gpio_ena','FiType','ufix32');
            adc_a_ofs=this.signal('Name','adc_a_ofs','FiType','ufix14');
            adc_b_ofs=this.signal('Name','adc_b_ofs','FiType','ufix14');
            phase=this.signal('Name','phase','FiType','ufix24');

            adc_i=this.signal('Name','adc_i','FiType','ufix18');
            scale_i=this.signal('Name','scale_i','FiType','ufix18');
            P_I=this.signal('Name','P_I','FiType','ufix36');
            adc_q=this.signal('Name','adc_q','FiType','ufix18');
            scale_q=this.signal('Name','scale_q','FiType','ufix18');
            P_Q=this.signal('Name','P_Q','FiType','ufix36');
            filter_out_i=this.signal('Name','filter_out_i','FiType','sfix18');
            filter_out_q=this.signal('Name','filter_out_q','FiType','sfix18');
            pi230=this.signal('Name','pi230','FiType','ufix24');
            pq230=this.signal('Name','pq230','FiType','ufix24');
            i_cordic=this.signal('Name','i_cordic','FiType','ufix24');
            q_cordic=this.signal('Name','q_cordic','FiType','ufix24');
            rate=this.signal('Name','rate','FiType','ufix8');
            load_rate=this.signal('Name','load_rate','FiType','boolean');


            this.component(...
            'Name','sr_0',...
            'Component',eda.usrp.setting_reg('my_addr','160'),...
            'clk',this.clk,...
            'rst',this.rst,...
            'strobe',this.set_stb,...
            'addr',this.set_addr,...
            'in',this.set_data,...
            'out',phase_inc,...
            'changed','OPEN');

            this.component(...
            'Name','sr_1',...
            'Component',eda.usrp.setting_reg('my_addr','161'),...
            'clk',this.clk,...
            'rst',this.rst,...
            'strobe',this.set_stb,...
            'addr',this.set_addr,...
            'in',this.set_data,...
            'out',scale,...
            'changed','OPEN');

            this.component(...
            'Name','sr_2',...
            'Component',eda.usrp.setting_reg('my_addr','162'),...
            'clk',this.clk,...
            'rst',this.rst,...
            'strobe',this.set_stb,...
            'addr',this.set_addr,...
            'in',this.set_data,...
            'out',enbANDRate,...
            'changed','OPEN');

            this.component(...
            'Name','sr_8',...
            'Component',eda.usrp.setting_reg('my_addr','168'),...
            'clk',this.clk,...
            'rst',this.rst,...
            'strobe',this.set_stb,...
            'addr',this.set_addr,...
            'in',this.set_data,...
            'out',muxctrl,...
            'changed','OPEN');

            this.component(...
            'Name','sr_9',...
            'Component',eda.usrp.setting_reg('my_addr','169'),...
            'clk',this.clk,...
            'rst',this.rst,...
            'strobe',this.set_stb,...
            'addr',this.set_addr,...
            'in',this.set_data,...
            'out',gpio_ena,...
            'changed','OPEN');

            this.component(...
            'Name','rx_dcoffset_a',...
            'Component',eda.usrp.rx_dcoffset('WIDTH','14','ADDR','166'),...
            'clk',this.clk,...
            'rst',this.rst,...
            'set_stb',this.set_stb,...
            'set_addr',this.set_addr,...
            'set_data',this.set_data,...
            'adc_in',this.adc_a,...
            'adc_out',adc_a_ofs);

            this.component(...
            'Name','rx_dcoffset_b',...
            'Component',eda.usrp.rx_dcoffset('WIDTH','14','ADDR','167'),...
            'clk',this.clk,...
            'rst',this.rst,...
            'set_stb',this.set_stb,...
            'set_addr',this.set_addr,...
            'set_data',this.set_data,...
            'adc_in',this.adc_b,...
            'adc_out',adc_b_ofs);

            this.component(...
            'Name','MULTIPLY_I',...
            'Component',eda.usrp.MULT18X18S,...
            'C',this.clk,...
            'CE','HIGH',...
            'R',this.rst,...
            'A',adc_i,...
            'B',scale_i,...
            'P',P_I);

            this.component(...
            'Name','MULTIPLY_Q',...
            'Component',eda.usrp.MULT18X18S,...
            'C',this.clk,...
            'CE','HIGH',...
            'R',this.rst,...
            'A',adc_q,...
            'B',scale_q,...
            'P',P_Q);

            this.component(...
            'Name','cordic',...
            'Component',eda.usrp.cordic_z24('bitwidth','24'),...
            'clock',this.clk,...
            'reset',this.rst,...
            'enable',this.run,...
            'xi',pi230,...
            'yi',pq230,...
            'zi',phase,...
            'xo',i_cordic,...
            'yo',q_cordic,...
            'zo','OPEN');

            this.component(...
            'Name','RxUSRPFilter',...
            'Component',eda.internal.component.filter.usrp2.USRPFilterRX,...
            'clk',this.clk,...
            'reset',this.rst,...
            'clk_enable',this.run,...
            'rate',rate,...
            'load_rate',load_rate,...
            'filter_in_re',i_cordic,...
            'filter_in_im',q_cordic,...
            'filter_out_re',filter_out_i,...
            'filter_out_im',filter_out_q,...
            'ce_out',this.strobe);

            this.component(...
            'Name','glueLogic',...
            'Component',eda.internal.usrp2impl.glueLogic_rx,...
            'clk',this.clk,...
            'rst',this.rst,...
            'run',this.run,...
            'scale',scale,...
            'muxctrl',muxctrl,...
            'adc_a_ofs',adc_a_ofs,...
            'adc_b_ofs',adc_b_ofs,...
            'phase_inc',phase_inc,...
            'enbANDRate',enbANDRate,...
            'adcAdj_i',adc_i,...
            'scaleAdj_i',scale_i,...
            'adcAdj_q',adc_q,...
            'scaleAdj_q',scale_q,...
            'prod_i',P_I,...
            'prod_q',P_Q,...
            'prod_i23_0',pi230,...
            'prod_q23_0',pq230,...
            'phase_31_8',phase,...
            'i_out',filter_out_i,...
            'q_out',filter_out_q,...
            'gpio_ena',gpio_ena,...
            'io_rx',this.io_rx,...
            'rate',rate,...
            'load_rate',load_rate,...
            'sample',this.sample);





        end

    end

end


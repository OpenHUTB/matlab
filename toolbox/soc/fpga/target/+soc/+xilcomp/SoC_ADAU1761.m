classdef SoC_ADAU1761<soc.xilcomp.XilinxComponentBase
    properties
    end

    methods
        function obj=SoC_ADAU1761(varargin)

            obj.Configuration={...
            'board_name','Xilinx Zynq ZC706 evaluation kit',...
            };

            if nargin>0
                obj.Configuration=varargin;
            end


            obj.Instance=[...
            '  # Create pins\n',...
            '  create_bd_port -dir IO -type data SCL\n',...
            '  create_bd_port -dir IO -type data SDA\n',...
            '  create_bd_port -dir O -type data ADDR0\n',...
            '  create_bd_port -dir O -type data ADDR1\n',...
            '  create_bd_port -dir O -type clk ADAU1761_CLK\n',...
            '  create_bd_port -dir O -type clk Serial_in\n',...
            '  create_bd_port -dir I -type clk Serial_out\n',...
            '  create_bd_port -dir I -type clk BCLK\n',...
            '  create_bd_port -dir I -type clk LRCLK\n',...
'\n'...

            ];




            obj.InstancePost=[
            ' # **** Clock Generation for ADAU1761 Codec **** \n',...
            ' set Codec_clock [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 Codec_clock]\n',...
            ' set_property -dict [list CONFIG.USE_LOCKED {false} CONFIG.USE_RESET {false}] [get_bd_cells Codec_clock]\n',...
            ' connect_bd_net [get_bd_pins Codec_clock/clk_in1] [get_bd_pins clkgen/clk_out1]\n',...
            ' # connect_bd_net [get_bd_ports ADAU1761_CLK] [get_bd_pins Codec_clock/clk_out1]\n',...
            '  set_property -dict [list CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {24.000} CONFIG.MMCM_DIVCLK_DIVIDE {5} CONFIG.MMCM_CLKFBOUT_MULT_F {50.250} CONFIG.MMCM_CLKOUT0_DIVIDE_F {41.875} CONFIG.CLKOUT1_JITTER {305.592} CONFIG.CLKOUT1_PHASE_ERROR {298.923}] [get_bd_cells Codec_clock]\n',...
'  connect_bd_net [get_bd_ports ADAU1761_CLK] [get_bd_pins Codec_clock/clk_out1]\n'...
            ];
            switch obj.Configuration.board_name
            case 'ZedBoard'
                obj.Constraint=[...
                '# adau1761 \n',...
                'set_property  -dict {PACKAGE_PIN  AB2 IOSTANDARD LVCMOS33} [get_ports ADAU1761_CLK];							 ## ADAU1761 Clock\n',...
                'set_property  -dict {PACKAGE_PIN  AB4 IOSTANDARD LVCMOS33} [get_ports SCL];							 		 ## I2C Clock\n',...
                'set_property  -dict {PACKAGE_PIN  AB5 IOSTANDARD LVCMOS33} [get_ports SDA];							 		 ## I2C Data\n',...
                'set_property  -dict {PACKAGE_PIN  AB1 IOSTANDARD LVCMOS33} [get_ports ADDR0];							 		 ## \n',...
                'set_property  -dict {PACKAGE_PIN  Y5 IOSTANDARD LVCMOS33} [get_ports ADDR1];							 		 ## I2C CLOCK Clock\n',...
                'set_property  -dict {PACKAGE_PIN  Y8 IOSTANDARD LVCMOS33} [get_ports Serial_in];							 	 ## Data_path\n',...
                'set_property  -dict {PACKAGE_PIN  AA7 IOSTANDARD LVCMOS33} [get_ports Serial_out];							 	 ## Data_path\n',...
                'set_property  -dict {PACKAGE_PIN  AA6 IOSTANDARD LVCMOS33} [get_ports BCLK];							 	 ## I2S_Bitclk\n',...
                'set_property  -dict {PACKAGE_PIN  Y6 IOSTANDARD LVCMOS33} [get_ports LRCLK];							 	 ## I2S_LRclk\n',...
                ];
            otherwise
                error(message('soc:msgs:componentNotSupportOnBoard','ADAU1761'));
            end
        end
    end
end

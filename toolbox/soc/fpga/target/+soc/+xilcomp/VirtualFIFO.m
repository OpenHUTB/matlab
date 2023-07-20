classdef VirtualFIFO<soc.xilcomp.XilinxComponentBase
    properties
    end

    methods
        function obj=VirtualFIFO(varargin)

            obj.Configuration={...
            's_dw','32',...
            'bsize','512',...
            'baddr','01000000',...
            'num_ch','2',...
            'num_page','63',...
            };

            if nargin>0
                obj.Configuration=varargin;
            end


            obj.addClk('axi_vfifo_ctrl/aclk','MemClk');
            obj.addRst('axi_vfifo_ctrl/aresetn','MemRstn');


            obj.addClk('axis_intc_dut2vfifo/M00_AXIS_ACLK','MemClk');
            obj.addClk('axis_intc_dut2vfifo/S00_AXIS_ACLK','IPCoreClk');
            obj.addClk('axis_intc_dut2vfifo/ACLK','SystemClk');

            obj.addRst('axis_intc_dut2vfifo/M00_AXIS_ARESETN','MemRstn');
            obj.addRst('axis_intc_dut2vfifo/S00_AXIS_ARESETN','IPCoreRstn');
            obj.addRst('axis_intc_dut2vfifo/ARESETN','SystemRstn');

            obj.addClk('axis_intc_vfifo2dut/M00_AXIS_ACLK','IPCoreClk');
            obj.addClk('axis_intc_vfifo2dut/S00_AXIS_ACLK','MemClk');
            obj.addClk('axis_intc_vfifo2dut/ACLK','SystemClk');

            obj.addRst('axis_intc_vfifo2dut/M00_AXIS_ARESETN','IPCoreRstn');
            obj.addRst('axis_intc_vfifo2dut/S00_AXIS_ARESETN','MemRstn');
            obj.addRst('axis_intc_vfifo2dut/ARESETN','SystemRstn');



            obj.addAXI4Master('axi_vfifo_ctrl/M_AXI','mem','mem');

            obj.Instance=[...
            'set axi_vfifo_ctrl [create_bd_cell -vlnv xilinx.com:ip:axi_vfifo_ctrl:2.0 axi_vfifo_ctrl]\n',...
'set_property -dict [list'...
            ,' CONFIG.axis_tdata_width ',obj.Configuration.s_dw,...
            ' CONFIG.axi_burst_size ',obj.Configuration.bsize,...
            ' CONFIG.dram_base_addr ',obj.Configuration.baddr,...
            ' CONFIG.number_of_channel ',obj.Configuration.num_ch,...
            ' CONFIG.number_of_page_ch0 ',obj.Configuration.num_page,...
            ' CONFIG.number_of_page_ch1 1',...
'] $axi_vfifo_ctrl\n'...
            ,'set axis_intc_dut2vfifo [create_bd_cell -vlnv xilinx.com:ip:axis_interconnect:2.1 axis_intc_dut2vfifo]\n',...
            'set_property -dict [list CONFIG.NUM_MI {1} CONFIG.NUM_SI {1}] $axis_intc_dut2vfifo\n',...
            'hsb_connect axis_intc_dut2vfifo/M00_AXIS axi_vfifo_ctrl/S_AXIS\n',...
            'set axis_intc_vfifo2dut [create_bd_cell -vlnv xilinx.com:ip:axis_interconnect:2.1 axis_intc_vfifo2dut]\n',...
            'set_property -dict [list CONFIG.NUM_MI {1} CONFIG.NUM_SI {1}] $axis_intc_vfifo2dut\n',...
            'hsb_connect axis_intc_vfifo2dut/S00_AXIS axi_vfifo_ctrl/M_AXIS\n',...
            ];
        end
    end
end

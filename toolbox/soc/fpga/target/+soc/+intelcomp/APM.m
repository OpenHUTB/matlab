classdef APM<soc.intelcomp.IntelComponentBase
    properties
Slots
        Mode='Profile';
CoreFrequency
SlotDw
        NumDMA=0
        DMA1FIFOdepth=2
        DMA2FIFOdepth=2
        DmaSlotIndex=[]
    end
    properties(Constant)
        MaxSlots=8
    end

    methods
        function obj=APM(varargin)


            obj.Configuration={...
            'dev_addr','0x00000000',...
            'dev_range','0',...
            'clock','',...
            'rstn','',...
            'fifo_size','1024',...
            };

            if nargin>0
                obj.Configuration=varargin;
            end


            obj.addAXI4Slave('MW_PerfMon.AXI4_Lite_Slave','reg','sys',obj.Configuration.dev_addr);
            obj.addClk('MW_PerfMon.AXI4_Lite_ACLK','SystemClk');
            obj.addRst('MW_PerfMon.AXI4_Lite_ARESETN','SystemRstn');

            obj.addClk('MW_PerfMon.CORE_ACLK',obj.Configuration.clock);
            obj.addRst('MW_PerfMon.CORE_ARESETN',obj.Configuration.rstn);

            obj.Instance=[...
            'add_instance MW_PerfMon MW_PerfMon 1.0\n',...
            'set_instance_parameter_value MW_PerfMon {FIFO_SIZE} {',obj.Configuration.fifo_size,'}\n'...
            ];

            obj.Instance=[obj.Instance,...
            'proc add_connection_pm {instance_name interface_name slot_idx} {\n',...
            'set intf ${instance_name}.${interface_name}\n',...
            'set all_ports [get_instance_interface_ports $instance_name $interface_name]\n',...
            'for {set i 0} {$i < [llength $all_ports]} {incr i} {\n',...
            '  set this_port [lindex $all_ports $i]\n',...
            '  set this_port_role [get_instance_interface_port_property $instance_name $interface_name $this_port Role]\n',...
            '  if {$this_port_role == "awaddr"} {\n',...
            '     set awaddr_port $this_port\n',...
            '  }\n',...
            '  if {$this_port_role == "wdata"} {\n',...
            '    set wdata_port $this_port\n',...
            '  }\n',...
            '}\n',...
            'set addr_width_prop [get_instance_interface_port_property $instance_name $interface_name $awaddr_port Width]\n',...
            'set data_width_prop [get_instance_interface_port_property $instance_name $interface_name $wdata_port Width]\n',...
            'set_instance_parameter_value MW_PerfMon SLOT_${slot_idx}_AXI_ADDR_WIDTH $addr_width_prop\n',...
            'set_instance_parameter_value MW_PerfMon SLOT_${slot_idx}_AXI_DATA_WIDTH $data_width_prop\n',...
            'add_connection $intf MW_PerfMon.SLOT_${slot_idx}_S_AXI\n',...
            'set_connection_parameter_value ${intf}/MW_PerfMon.SLOT_${slot_idx}_S_AXI arbitrationPriority {1}\n',...
            'set_connection_parameter_value ${intf}/MW_PerfMon.SLOT_${slot_idx}_S_AXI baseAddress {0x0000}\n',...
            'set_connection_parameter_value ${intf}/MW_PerfMon.SLOT_${slot_idx}_S_AXI defaultConnection {0}\n',...
            '}\n'];
        end

        function bridge_output=addSlot(obj,m_axi,m_config,verbose)

            obj.Slots=[obj.Slots,m_axi];
            numSlots=numel(obj.Slots);

            if find(contains(m_axi.name,{'dma_s2mm','dma_mm2s'}))
                obj.DmaSlotIndex=[obj.DmaSlotIndex,numel(obj.Slots)];
                obj.NumDMA=obj.NumDMA+1;
                if(find(contains(m_axi.name,'dma_s2mm')))
                    dmaPort='dma_s2mm.diagnostics_if';
                else
                    dmaPort='dma_mm2s.diagnostics_if';
                end
                if(obj.NumDMA==1)
                    obj.DMA1FIFOdepth=m_config.fifo_depth;
                    obj.Instance=[obj.Instance,...
                    'set_instance_parameter_value MW_PerfMon {NUM_DMAS} {',num2str(obj.NumDMA),'}\n'...
                    ,'set_instance_parameter_value MW_PerfMon {FIFO1_BUFFER_DEPTH} {',num2str(obj.DMA1FIFOdepth),'}\n'...
                    ,'set_instance_parameter_value MW_PerfMon {DMA1_SLOT_INDEX} {',num2str(numSlots-1),'}\n'...
                    ,'add_connection MW_PerfMon.dma1_burstcnt ',dmaPort,'\n',...
                    ];
                else
                    obj.DMA2FIFOdepth=m_config.fifo_depth;
                    obj.Instance=[obj.Instance,...
                    'set_instance_parameter_value MW_PerfMon {NUM_DMAS} {',num2str(obj.NumDMA),'}\n'...
                    ,'set_instance_parameter_value MW_PerfMon {FIFO2_BUFFER_DEPTH} {',num2str(obj.DMA2FIFOdepth),'}\n'...
                    ,'set_instance_parameter_value MW_PerfMon {DMA2_SLOT_INDEX} {',num2str(numSlots-1),'}\n'...
                    ,'add_connection MW_PerfMon.dma2_burstcnt ',dmaPort,'\n',...
                    ];
                end
            end

            if numSlots>obj.MaxSlots
                error(message('soc:msgs:diagMonitorExceedAvailableSlot'));
            end
            obj.addClk(['MW_PerfMon.SLOT_',num2str(numSlots-1),'_AXI_ACLK'],type2ClkName(obj,m_axi.clkRstn));
            obj.addRst(['MW_PerfMon.SLOT_',num2str(numSlots-1),'_AXI_ARESETN'],type2RstnName(obj,m_axi.clkRstn));
            obj.Instance=[obj.Instance,...
            'set_instance_parameter_value MW_PerfMon {NUM_SLOTS} {',num2str(numSlots),'}\n'...
            ,'add_connection_pm ',extractBefore(m_axi.name,'.'),' ',extractAfter(m_axi.name,'.'),' ',num2str(numSlots-1),'\n',...
            ];
            bridge_output=['MW_PerfMon.SLOT_',num2str(numSlots-1),'_M_AXI'];
            if verbose
                fprintf('### Assigning %s to Performance Monitor Slot %d\n',m_axi.name,numSlots-1);
            end
        end
    end
end


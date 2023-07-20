classdef APM<soc.xilcomp.XilinxComponentBase
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


            obj.addAXI4Slave('MW_PerfMon/AXI4_Lite_Slave','reg','sys',obj.Configuration.dev_addr,obj.Configuration.dev_range);
            obj.addClk('MW_PerfMon/AXI4_Lite_ACLK','SystemClk');
            obj.addRst('MW_PerfMon/AXI4_Lite_ARESETN','SystemRstn');

            obj.addClk('MW_PerfMon/CORE_ACLK',obj.Configuration.clock);
            obj.addRst('MW_PerfMon/CORE_ARESETN',obj.Configuration.rstn);

            obj.Instance=[...
            'set MW_PerfMon [create_bd_cell -vlnv mathworks.com:user:MW_PerfMon:1.0 MW_PerfMon]\n',...
            'set_property -dict [list CONFIG.FIFO_SIZE ',obj.Configuration.fifo_size,...
'] $MW_PerfMon\n'...
            ];
        end

        function bridge_output=addSlot(obj,m_axi,m_config,verbose)
            obj.Slots=[obj.Slots,m_axi];
            numSlots=numel(obj.Slots);

            if startsWith(m_axi.name,{'dma_s2mm','dma_mm2s'})
                obj.DmaSlotIndex=[obj.DmaSlotIndex,numel(obj.Slots)];
                obj.NumDMA=obj.NumDMA+1;
                if(find(contains(m_axi.name,'dma_s2mm')))
                    dmaPort='dma_s2mm/dest_diag_level_bursts';
                else
                    dmaPort='dma_mm2s/dest_diag_level_bursts';
                end
                if(obj.NumDMA==1)
                    obj.DMA1FIFOdepth=m_config.fifo_depth;
                    obj.Instance=[obj.Instance,...
                    'set_property CONFIG.NUM_DMAS ',num2str(obj.NumDMA),' $MW_PerfMon\n'...
                    ,'set_property CONFIG.FIFO1_BUFFER_DEPTH ',num2str(obj.DMA1FIFOdepth),' $MW_PerfMon\n'...
                    ,'set_property CONFIG.DMA1_SLOT_INDEX ',num2str(numSlots-1),' $MW_PerfMon\n'...
                    ,'hsb_connect MW_PerfMon/dma1_burstcnt ',dmaPort,'\n',...
                    ];
                else
                    obj.DMA2FIFOdepth=m_config.fifo_depth;
                    obj.Instance=[obj.Instance,...
                    'set_property CONFIG.NUM_DMAS ',num2str(obj.NumDMA),' $MW_PerfMon\n'...
                    ,'set_property CONFIG.FIFO2_BUFFER_DEPTH ',num2str(obj.DMA2FIFOdepth),' $MW_PerfMon\n'...
                    ,'set_property CONFIG.DMA2_SLOT_INDEX ',num2str(numSlots-1),' $MW_PerfMon\n'...
                    ,'hsb_connect MW_PerfMon/dma2_burstcnt ',dmaPort,'\n',...
                    ];
                end
            end

            if numSlots>obj.MaxSlots
                error(message('soc:msgs:diagMonitorExceedAvailableSlot'));
            end
            obj.addClk(['MW_PerfMon/SLOT_',num2str(numSlots-1),'_AXI_ACLK'],type2ClkName(obj,m_axi.clk_rstn));
            obj.addRst(['MW_PerfMon/SLOT_',num2str(numSlots-1),'_AXI_ARESETN'],type2RstnName(obj,m_axi.clk_rstn));
            obj.Instance=[obj.Instance,...
            'set_property CONFIG.NUM_SLOTS ',num2str(numSlots),' $MW_PerfMon\n'...
            ,'hsb_connect MW_PerfMon/SLOT_',num2str(numSlots-1),'_S_AXI ',m_axi.name,'\n',...
            ];
            bridge_output=['MW_PerfMon/SLOT_',num2str(numSlots-1),'_M_AXI'];
            if verbose
                fprintf('### Assigning %s to Performance Monitor Slot %d\n',m_axi.name,numSlots-1);
            end
        end
    end
end


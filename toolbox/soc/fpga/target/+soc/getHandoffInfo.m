function socsysinfo=getHandoffInfo(hbuild)



    dut=hbuild.DUTName;
    topSys=hbuild.TopSystemName;
    memMap=hbuild.MemMap;
    [fpgaModelBlock,fpgaModel]=soc.util.getHSBSubsystem(topSys);


    axi_regs_info=struct('name',{},'data_type',{},'vec_length',{},'offset',{},'default_val',{},'direction',{},'reg_blk',{});
    axi_masters_info=struct('type',{},'mm_dw',{},'mwipcore',{},'mem_addr',{},'mem_range',{},'blk_name',{});
    mwipcore_info=struct('ipcore_name',{},'base_addr',{},'axi_regs',{},'blk_name',{},'interrupt',{});
    dma_info=struct('type',{},'base_addr',{},'irq_num',{},'mm_dw',{},'mwipcore',{},'s_dw',{},'sw_dw',{},'mem_addr',{},'mem_range',{},...
    'burst_size',{},'fifo_depth',{},'dma_blk',{},'bufferSize',{},'irq_triggerType',{});
    vdma_info=struct('type',{},'base_addr',{},'mm_dw',{},'mwipcore',{},'s_dw',{},'mem_addr',{},'mem_range',{},...
    'burst_size',{},'buf_depth',{},'vdma_blk',{},'frame_size',{});
    vdma_fifo_info=struct('type',{},'base_addr',{},'base_addr1',{},'mm2s_mm_dw',{},'mwipcore',{},'mm2s_s_dw',{},...
    's2mm_mm_dw',{},'s2mm_s_dw',{},'mem_addr',{},'mem_range',{},'mm2s_buf_depth',{},'s2mm_buf_depth',{},'mm2s_burst_size',{},...
    's2mm_burst_size',{},'vdma_blk',{});
    perf_mon_info=struct('base_addr',{},'mode',{},'num_slots',{},'blk_name',{},'metric_clock_freq',{},'slot_dw',{},'NumDmas',{},'DmaSlotIndex',{});
    ATGInfo=struct('base_addr',{},'blk_name',{},'clock_freq',{},'rw_dir',{},'bsize',{},...
    'mem_width',{},'periods',{},'mem_addr',{});
    customipcore_info=struct('ipcore_name',{},'dtsi',{},'SInterfaces',{},'PostProgramSoCFcn',{},'frameSizeForHDMI',{},'PostProgramSoCFcnArgs',{},'PreProgramSoCFcn',{},'PreProgramSoCFcnArgs',{},'isUserDefined',{});

    map_axi2dut=containers.Map;
    for i=1:numel(hbuild.ComponentList)
        this_comp=hbuild.ComponentList{i};
        if hbuild.HasReferenceDesign


            if~isa(this_comp,'soc.xilcomp.DUT')
                continue;
            end
        end
        if isa(this_comp,'soc.xilcomp.DUT')
            intrInfo=this_comp.Interrupt;
            mwipcore_info=[mwipcore_info...
            ,struct(...
            'ipcore_name',this_comp.Name,...
            'base_addr',this_comp.AXI4Slave.offset,...
            'axi_regs',axi_regs_info,...
            'blk_name',this_comp.BlkName,...
            'interrupt',intrInfo...
            )];
            mwipcore_info(end).axi_regs=set_basic_reg(this_comp);

        elseif isa(this_comp,'soc.xilcomp.AXIM')||isa(this_comp,'soc.intelcomp.AXIM')
            axi_masters_info=[axi_masters_info...
            ,struct(...
            'type',this_comp.Configuration.type,...
            'mm_dw',this_comp.Configuration.mm_dw,...
            'mwipcore','',...
            'mem_addr',this_comp.Configuration.mem_addr,...
            'mem_range',this_comp.Configuration.mem_range,...
            'blk_name',this_comp.BlkName...
            )];
        elseif isa(this_comp,'soc.xilcomp.DMAWrite')||isa(this_comp,'soc.intelcomp.DMAWrite')
            dma_info=[dma_info...
            ,struct(...
            'type','dma_write',...
            'base_addr',this_comp.AXI4Slave.offset,...
            'irq_num',num2str(this_comp.Interrupt.irq_num),...
            'mm_dw',this_comp.Configuration.mm_dw,...
            's_dw',this_comp.Configuration.s_dw,...
            'sw_dw',this_comp.Configuration.sw_dw,...
            'mwipcore','',...
            'mem_addr',this_comp.Configuration.mem_addr,...
            'mem_range',this_comp.Configuration.mem_range,...
            'burst_size',this_comp.Configuration.bsize,...
            'fifo_depth',this_comp.Configuration.fifo_depth,...
            'dma_blk',this_comp.BlkName,...
            'bufferSize',this_comp.Configuration.bufferSize,...
            'irq_triggerType',this_comp.Interrupt.triggerType...
            )];
        elseif isa(this_comp,'soc.xilcomp.DMARead')||isa(this_comp,'soc.intelcomp.DMARead')
            dma_info=[dma_info...
            ,struct(...
            'type','dma_read',...
            'base_addr',this_comp.AXI4Slave.offset,...
            'irq_num',num2str(this_comp.Interrupt.irq_num),...
            'mm_dw',this_comp.Configuration.mm_dw,...
            's_dw',this_comp.Configuration.s_dw,...
            'sw_dw',this_comp.Configuration.sw_dw,...
            'mwipcore','',...
            'mem_addr',this_comp.Configuration.mem_addr,...
            'mem_range',this_comp.Configuration.mem_range,...
            'burst_size',this_comp.Configuration.bsize,...
            'fifo_depth',this_comp.Configuration.fifo_depth,...
            'dma_blk',this_comp.BlkName,...
            'bufferSize',this_comp.Configuration.bufferSize,...
            'irq_triggerType',this_comp.Interrupt.triggerType...
            )];
        elseif isa(this_comp,'soc.xilcomp.VDMARead')
            frame_size=this_comp.FrameSize;
            vdma_info=[vdma_info...
            ,struct(...
            'type','vdma_read',...
            'base_addr',this_comp.AXI4Slave(1).offset,...
            'mm_dw',this_comp.Configuration.mm_dw,...
            's_dw',this_comp.Configuration.s_dw,...
            'mwipcore','',...
            'mem_addr',this_comp.Configuration.mem_addr,...
            'mem_range',this_comp.Configuration.mem_range,...
            'burst_size',this_comp.Configuration.bsize,...
            'buf_depth',this_comp.Configuration.buf_depth,...
            'vdma_blk',this_comp.BlkName,...
            'frame_size',frame_size...
            )];
        elseif isa(this_comp,'soc.xilcomp.VDMAWrite')
            frame_size=struct('width',[],'height',[],'hporch',[],'vporch',[]);
            vdma_info=[vdma_info...
            ,struct('type','vdma_write',...
            'base_addr',this_comp.AXI4Slave.offset,...
            'mm_dw',this_comp.Configuration.mm_dw,...
            's_dw',this_comp.Configuration.s_dw,...
            'mwipcore','',...
            'mem_addr',this_comp.Configuration.mem_addr,...
            'mem_range',this_comp.Configuration.mem_range,...
            'burst_size',this_comp.Configuration.bsize,...
            'buf_depth',this_comp.Configuration.buf_depth,...
            'vdma_blk',this_comp.BlkName,...
            'frame_size',frame_size...
            )];
        elseif isa(this_comp,'soc.xilcomp.VDMAFrameBuffer')
            vdma_fifo_info=[vdma_fifo_info...
            ,struct(...
            'type','vdma_fifo',...
            'base_addr',this_comp.AXI4Slave(1).offset,...
            'base_addr1',this_comp.AXI4Slave(2).offset,...
            'mm2s_mm_dw',this_comp.Configuration.mm2s_mm_dw,...
            'mm2s_s_dw',this_comp.Configuration.mm2s_s_dw,...
            'mwipcore','',...
            's2mm_mm_dw',this_comp.Configuration.s2mm_mm_dw,...
            's2mm_s_dw',this_comp.Configuration.s2mm_s_dw,...
            'mem_addr',this_comp.Configuration.mem_addr,...
            'mem_range',this_comp.Configuration.mem_range,...
            'mm2s_buf_depth',this_comp.Configuration.mm2s_buf_depth,...
            's2mm_buf_depth',this_comp.Configuration.s2mm_buf_depth,...
            'mm2s_burst_size',this_comp.Configuration.mm2s_bsize,...
            's2mm_burst_size',this_comp.Configuration.s2mm_bsize,...
            'vdma_blk',this_comp.BlkName...
            )];
        elseif isa(this_comp,'soc.xilcomp.APM')||isa(this_comp,'soc.intelcomp.APM')
            perf_mon_info=[perf_mon_info...
            ,struct(...
            'base_addr',this_comp.AXI4Slave.offset,...
            'mode',this_comp.Mode,...
            'num_slots',numel(this_comp.Slots),...
            'blk_name',this_comp.BlkName,...
            'metric_clock_freq',this_comp.CoreFrequency,...
            'slot_dw',this_comp.SlotDw,...
            'NumDmas',this_comp.NumDMA,...
            'DmaSlotIndex',this_comp.DmaSlotIndex...
            )];
        elseif isa(this_comp,'soc.xilcomp.ATG')||isa(this_comp,'soc.intelcomp.ATG')
            memclk=this_comp.type2ClkName(this_comp.Configuration.mem_type);
            ATGInfo=[ATGInfo...
            ,struct(...
            'base_addr',this_comp.AXI4Slave.offset,...
            'blk_name',this_comp.BlkName,...
            'clock_freq',hbuild.(memclk).freq,...
            'rw_dir',this_comp.Configuration.rw_dir,...
            'bsize',this_comp.Configuration.bsize,...
            'mem_width',this_comp.Configuration.mm_dw,...
            'periods',this_comp.Configuration.period,...
            'mem_addr',this_comp.Configuration.mem_addr...
            )];
        elseif isa(this_comp,'soc.intelcomp.DUT')
            intrInfo=this_comp.Interrupt;
            mwipcore_info=[mwipcore_info...
            ,struct('ipcore_name',this_comp.Name,'base_addr',this_comp.AXI4Slave.offset,'axi_regs',axi_regs_info,'blk_name',this_comp.BlkName,'interrupt',intrInfo)];
            mwipcore_info(end).axi_regs=set_basic_reg(this_comp);
        end
    end

    if~hbuild.HasReferenceDesign
        for nn=1:numel(hbuild.FMCIO)
            this_fmc_io=hbuild.FMCIO{nn};
            switch class(this_fmc_io)
            case 'soc.xilcomp.AD9361'
                customipcore_info=[customipcore_info...
                ,struct('ipcore_name','AD9361',...
                'dtsi',fullfile('$(DTS_REPOSITORY_ROOT)','templates','ad9361.dtsi'),...
                'SInterfaces',this_fmc_io.AXI4Slave,...
                'PostProgramSoCFcn','soc.internal.ui.AD9361Setup',...
                'frameSizeForHDMI',[],...
                'PostProgramSoCFcnArgs',[],...
                'PreProgramSoCFcn','',...
                'PreProgramSoCFcnArgs',[],...
                'isUserDefined',false...
                )];
            case 'soc.xilcomp.HDMIRx'

                indx=cellfun(@(x)isprop(x,'AXIInterface')&&any(contains(x.AXIInterface,'AXI4-Stream Video')),hbuild.ComponentList);
                videoStreamDUT=hbuild.ComponentList(indx);
                fcnArgs=struct('ipcoreNameDUT','',...
                'numSlvInterfacesDUT',[]);
                for i=1:numel(videoStreamDUT)
                    slaveMatch=cellfun(@(x)regexp(x,'AXI4-Stream Video \d* Slave','match'),videoStreamDUT{i}.AXIInterface,'UniformOutput',false);
                    numSlvInterfaces=nnz(cellfun(@(x)~isempty(x),slaveMatch));
                    fcnArgs(i)=struct('ipcoreNameDUT',videoStreamDUT{i}.Name,...
                    'numSlvInterfacesDUT',numSlvInterfaces);
                end

                customipcore_info=[customipcore_info...
                ,struct('ipcore_name','HDMIRx',...
                'dtsi',fullfile('$(DTS_REPOSITORY_ROOT)','templates','hdmi.dtsi'),...
                'SInterfaces',this_fmc_io.AXI4Slave,...
                'PostProgramSoCFcn','soc.internal.ui.HDMISetup',...
                'frameSizeForHDMI',this_fmc_io.frameSize,...
                'PostProgramSoCFcnArgs',fcnArgs,...
                'PreProgramSoCFcn','',...
                'PreProgramSoCFcnArgs',[],...
                'isUserDefined',false...
                )];
            case 'soc.xilcomp.RFDataConverter'
                customipcore_info=[customipcore_info...
                ,struct('ipcore_name','RFDataConverter',...
                'dtsi',fullfile('$(DTS_REPOSITORY_ROOT)','templates','rfdc.dtsi'),...
                'SInterfaces',this_fmc_io.AXI4Slave,...
                'PostProgramSoCFcn','',...
                'frameSizeForHDMI',[],...
                'PostProgramSoCFcnArgs',[],...
                'PreProgramSoCFcn','soc.internal.ui.RFDCSetup',...
                'PreProgramSoCFcnArgs',this_fmc_io.IPConfigInfo,...
                'isUserDefined',false...
                )];
            otherwise

            end
        end

        for nn=1:numel(hbuild.CustomIP)
            this_custom_ip=hbuild.CustomIP{nn};

            if strcmpi(class(this_custom_ip),'soc.xilcomp.CustomIP')
                customipcore_info=[customipcore_info...
                ,struct('ipcore_name',this_custom_ip.CustomIPParams.ipInstanceName,...
                'dtsi',this_custom_ip.CustomIPParams.dtsiFilePath,...
                'SInterfaces',[],...
                'PostProgramSoCFcn',this_custom_ip.CustomIPParams.postProgFuncPath,...
                'frameSizeForHDMI',[],...
                'PostProgramSoCFcnArgs',[],...
                'PreProgramSoCFcn',this_custom_ip.CustomIPParams.preProgFuncPath,...
                'PreProgramSoCFcnArgs',[],...
                'isUserDefined',true...
                )];
            end
        end
    end




    if~isempty(fpgaModelBlock)
        inp=find_system(fpgaModel,'SearchDepth',1,'BlockType','Inport');
        outp=find_system(fpgaModel,'SearchDepth',1,'BlockType','Outport');


        hsbSubsysTop=fpgaModelBlock;
        mdlRefParent=get_param(fpgaModelBlock,'Parent');
        if~strcmp(mdlRefParent,bdroot(fpgaModelBlock))
            hsbSubsysTop=mdlRefParent;
        end

        h_all_ports=get_param(hsbSubsysTop,'PortHandles');
        h_inp=h_all_ports.Inport;
        h_outp=h_all_ports.Outport;

        for ii=1:numel(h_inp)
            this_h_inp=h_inp(ii);
            hsb_mdlref_port=soc.util.getModelRefPort(hsbSubsysTop,fpgaModelBlock,inp,ii,'in');
            if isempty(hsb_mdlref_port)


                continue;
            end
            h_line=get_param(this_h_inp,'Line');
            [src_blk,~,~,h_src_port]=soc.util.getHSBSrcBlk(h_line);
            if isempty(src_blk)&&hbuild.HasReferenceDesign


                continue;
            end

            h_hsb_mdlref_port_lines=get_param(hsb_mdlref_port,'LineHandles');
            h_line=h_hsb_mdlref_port_lines.Outport;
            cntd_blks=soc.util.getDstBlk(h_line);
            if~isempty(cntd_blks)
                cntd_blk=cntd_blks{1};
                if any(strcmpi(get_param(cntd_blk,'Name'),dut))
                    ipcore_name=soc.util.getIPCoreName(cntd_blk);
                    dut_idx=arrayfun(@(x)strcmpi(x.ipcore_name,ipcore_name),mwipcore_info);
                    if isKey(map_axi2dut,src_blk)&&strcmpi(soc.util.getRefBlk(src_blk),{'socmemlib/Register Channel'})
                        d=map_axi2dut(src_blk);
                        if~strcmpi(d.ipcore_name,ipcore_name)
                            error(message('soc:msgs:oneregchan2multips',src_blk,d.ipcore_name,ipcore_name));
                        end
                    else
                        dut_ip.name=get_param(cntd_blk,'Name');
                        dut_ip.ipcore_name=ipcore_name;
                        map_axi2dut(src_blk)=dut_ip;
                    end
                    if(any(strcmpi(soc.util.getRefBlk(src_blk),{'socmemlib/Register Channel'})))
                        reg_port=find_system(src_blk,'LookUnderMasks','all','FollowLinks','on','SearchDepth',1,'BlockType','Outport','Port',num2str(get_param(h_src_port,'PortNumber')));
                        reg_name=get_param(reg_port{1},'PortName');
                        reg_num=str2double(reg_name(regexp(reg_name,'[0-9]')));
                        this_reg_info=get_reg_info(src_blk,reg_num,memMap,map_axi2dut(src_blk).name);
                        mwipcore_info(dut_idx).axi_regs=[mwipcore_info(dut_idx).axi_regs,this_reg_info];
                    elseif(any(strcmpi(soc.util.getRefBlk(src_blk),{'hsblib_beta2/Register Channel','socregisterchanneli2clib/Register Channel I2C'})))

                        this_reg_info=get_reg_info_deprecated(src_blk,h_src_port,memMap,map_axi2dut(src_blk).name);
                        mwipcore_info(dut_idx).axi_regs=[mwipcore_info(dut_idx).axi_regs,this_reg_info];
                    elseif strcmpi(soc.util.getRefBlk(src_blk),'socmemlib/Memory Channel')...
                        &&strcmpi(get_param(src_blk,'ProtocolReader'),'AXI4-Stream')...
                        &&strcmpi(get_param(src_blk,'ProtocolWriter'),'AXI4-Stream Software')
                        if~isempty(dma_info)
                            dma_idx=arrayfun(@(x)strcmpi(x.type,'dma_read'),dma_info);
                            dma_info(dma_idx).mwipcore=ipcore_name;
                        end
                    elseif strcmpi(soc.util.getRefBlk(src_blk),'socmemlib/Software to AXI4-Stream')
                        if~isempty(dma_info)
                            dma_idx=arrayfun(@(x)strcmpi(x.type,'dma_read'),dma_info);
                            dma_info(dma_idx).mwipcore=ipcore_name;
                        end
                    end
                end
            end
        end

        for jj=1:numel(h_outp)
            this_h_outp=h_outp(jj);
            hsb_mdlref_port=soc.util.getModelRefPort(hsbSubsysTop,fpgaModelBlock,outp,jj,'out');
            if isempty(hsb_mdlref_port)


                continue;
            end
            h_line=get_param(this_h_outp,'Line');
            [dst_blks,~,~,h_dst_ports]=soc.util.getHSBDstBlk(h_line);
            if~isempty(dst_blks)
                dst_blk=dst_blks{1};
                h_dst_port=h_dst_ports(1);
            elseif hbuild.HasReferenceDesign


                continue;
            else
                dst_blk='';
                h_dst_port='';
            end

            h_hsb_mdlref_port_lines=get_param(hsb_mdlref_port,'LineHandles');
            h_line=h_hsb_mdlref_port_lines.Inport;
            cntd_blk=soc.util.getSrcBlk(h_line);
            if~isempty(cntd_blk)
                if any(strcmpi(get_param(cntd_blk,'Name'),dut))
                    ipcore_name=soc.util.getIPCoreName(cntd_blk);
                    dut_idx=arrayfun(@(x)strcmpi(x.ipcore_name,ipcore_name),mwipcore_info);
                    if isKey(map_axi2dut,dst_blk)&&strcmpi(soc.util.getRefBlk(dst_blk),{'socmemlib/Register Channel'})
                        d=map_axi2dut(dst_blk);
                        if~strcmpi(d.ipcore_name,ipcore_name)
                            error(message('soc:msgs:oneregchan2multips',dst_blk,d.ipcore_name,ipcore_name));
                        end
                    else
                        dut_ip.name=get_param(cntd_blk,'Name');
                        dut_ip.ipcore_name=ipcore_name;
                        map_axi2dut(dst_blk)=dut_ip;
                    end
                    if(any(strcmpi(soc.util.getRefBlk(dst_blk),{'socmemlib/Register Channel'})))
                        reg_port=find_system(dst_blk,'LookUnderMasks','all','FollowLinks','on','SearchDepth',1,'BlockType','Inport','Port',num2str(get_param(h_dst_ports,'PortNumber')));
                        reg_name=get_param(reg_port{1},'PortName');
                        reg_num=str2double(reg_name(regexp(reg_name,'[0-9]')));
                        this_reg_info=get_reg_info(dst_blk,reg_num,memMap,map_axi2dut(dst_blk).name);
                        mwipcore_info(dut_idx).axi_regs=[mwipcore_info(dut_idx).axi_regs,this_reg_info];
                    elseif(any(strcmpi(soc.util.getRefBlk(dst_blk),{'hsblib_beta2/Register Channel','socregisterchanneli2clib/Register Channel I2C'})))

                        this_reg_info=get_reg_info_deprecated(dst_blk,h_dst_port,memMap,map_axi2dut(dst_blk).name);
                        mwipcore_info(dut_idx).axi_regs=[mwipcore_info(dut_idx).axi_regs,this_reg_info];
                    elseif strcmpi(soc.util.getRefBlk(dst_blk),'socmemlib/Memory Channel')
                        if(strcmpi(get_param(dst_blk,'ProtocolReader'),'AXI4-Stream Software')...
                            ||strcmpi(get_param(dst_blk,'ProtocolReader'),'AXI4-Stream'))...
                            &&strcmpi(get_param(dst_blk,'ProtocolWriter'),'AXI4-Stream')
                            if~isempty(dma_info)
                                dma_idx=arrayfun(@(x)strcmpi(x.type,'dma_write'),dma_info);
                                dma_info(dma_idx).mwipcore=ipcore_name;
                            end
                        elseif strcmpi(get_param(dst_blk,'ProtocolReader'),'AXI4-Stream Video with Frame Sync')...
                            &&strcmpi(get_param(dst_blk,'ProtocolWriter'),'AXI4-Stream Video')
                            if~isempty(vdma_fifo_info)
                                vdma_fifo_idx=arrayfun(@(x)strcmpi(x.type,'vdma_fifo'),vdma_fifo_info);
                                vdma_fifo_info(vdma_fifo_idx).mwipcore=ipcore_name;
                            end
                        end
                    elseif strcmpi(soc.util.getRefBlk(dst_blk),'socmemlib/AXI4-Stream to Software')
                        if~isempty(dma_info)
                            dma_idx=arrayfun(@(x)strcmpi(x.type,'dma_write'),dma_info);
                            dma_info(dma_idx).mwipcore=ipcore_name;
                        end
                    elseif strcmpi(soc.util.getRefBlk(dst_blk),'socmemlib/AXI4 Video Frame Buffer')
                        if~isempty(vdma_fifo_info)
                            vdma_fifo_idx=arrayfun(@(x)strcmpi(x.type,'vdma_fifo'),vdma_fifo_info);
                            vdma_fifo_info(vdma_fifo_idx).mwipcore=ipcore_name;
                        end
                    end
                end
            end
        end
    end


    for i=1:numel(mwipcore_info)
        thisBlk=mwipcore_info(i).blk_name;
        [tunableParamNames,tunableParamDims,tunableParamDTypes,tunableParamValues]=soc.internal.getTunableParameter(thisBlk);
        for j=1:numel(tunableParamNames)
            regOffset=soc.memmap.getRegOffset(memMap,get_param(thisBlk,'Name'),tunableParamNames{j});
            reg_info=struct(...
            'name',tunableParamNames{j},...
            'data_type',tunableParamDTypes{j},...
            'vec_length',prod(tunableParamDims{j}),...
            'offset',regOffset(3:end),...
            'default_val',tunableParamValues{j},...
            'direction','write',...
            'reg_blk',''...
            );
            mwipcore_info(i).axi_regs=[mwipcore_info(i).axi_regs,reg_info];
        end
    end

    prj_dir=hbuild.ProjectDir;
    if~isfolder(prj_dir)
        mkdir(prj_dir);
    end

    if any(cellfun(@(x)isa(x,'soc.xilcomp.JTAGMaster'),hbuild.ComponentList))||any(cellfun(@(x)isa(x,'soc.intelcomp.JTAGMaster'),hbuild.ComponentList))
        jtag_file=fullfile(prj_dir,[topSys,'_aximaster.m']);
    else
        jtag_file='';
    end

    modelinfo.sys=topSys;
    modelinfo.fpga_model=fpgaModel;
    modelinfo.map_axi2dut=map_axi2dut;
    ipcoreinfo.mwipcore_info=mwipcore_info;
    ipcoreinfo.axi_masters_info=axi_masters_info;
    ipcoreinfo.dma_info=dma_info;
    ipcoreinfo.vdma_info=vdma_info;
    ipcoreinfo.vdma_fifo_info=vdma_fifo_info;
    ipcoreinfo.customipcore_info=customipcore_info;
    ipcoreinfo.perf_mon_info=perf_mon_info;
    ipcoreinfo.ATGInfo=ATGInfo;
    projectinfo.prj_dir=prj_dir;
    projectinfo.bit_file=fullfile(prj_dir,hbuild.BitName);
    projectinfo.board=hbuild.Board.BoardID;
    projectinfo.fullboardname=hbuild.Board.Name;
    projectinfo.vendor=hbuild.Vendor;
    if~hbuild.HasReferenceDesign
        projectinfo.ipinfofile=fullfile(prj_dir,[topSys,'_',projectinfo.board,'_aximaster.mat']);
        projectinfo.report=fullfile(prj_dir,'html',[topSys,'_system_report.html']);
        projectinfo.jtag_file=jtag_file;
    end
    socsysinfo.modelinfo=modelinfo;
    socsysinfo.ipcoreinfo=ipcoreinfo;
    socsysinfo.projectinfo=projectinfo;
    save(fullfile(prj_dir,'socsysinfo.mat'),'socsysinfo');
end

function reg_info=get_reg_info(reg_blk,reg_num,memMap,dutName)
    reg_table_names=evalin('base',get_param(reg_blk,'RegTableNames'));

    reg_vec_lengths=evalin('base',get_param(reg_blk,'RegTableVectorSizes'));
    reg_table_rw=evalin('base',get_param(reg_blk,'RegTableRW'));
    reg_table_defaults=evalin('base',get_param(reg_blk,'RegTableDefaultValues'));

    this_reg_offset=soc.memmap.getRegOffset(memMap,dutName,reg_table_names{reg_num});
    this_default_val=reg_table_defaults{reg_num}(regexp(reg_table_defaults{reg_num},'[a-f 0-9]','ignorecase'));

    switch(reg_table_rw{reg_num})
    case{'W','w','Write','write'}
        reg_dir='write';
    case{'R','r','Read','read'}
        reg_dir='read';
    end
    reg_info=struct(...
    'name',reg_table_names{reg_num},...
    'data_type','uint32',...
    'vec_length',str2double(reg_vec_lengths{reg_num}),...
    'offset',this_reg_offset(3:end),...
    'default_val',hex2dec(this_default_val),...
    'direction',reg_dir,...
    'reg_blk',reg_blk...
    );

    if reg_info.vec_length>1
        strobe_reg=reg_info;
        strobe_reg.name=[reg_info.name,'_strobe'];
        strobe_reg.data_type='uint32';
        strobe_reg.offset=dec2hex(2^ceil(log2((reg_info.vec_length)*4))+hex2dec(reg_info.offset),4);
        reg_info=[reg_info,strobe_reg];
    end

end

function reg_info=get_reg_info_deprecated(reg_blk,h_port,memMap,dutName)
    reg_table_names=evalin('base',get_param(reg_blk,'RegTableNames'));

    reg_vec_lengths=evalin('base',get_param(reg_blk,'RegisterVectorLengths'));
    reg_num=get_param(h_port,'PortNumber');

    this_reg_offset=soc.memmap.getRegOffset(memMap,dutName,reg_table_names{reg_num});
    default_vals=eval(get_param(reg_blk,'RegTableDefaultValues'));
    index=regexp(default_vals{reg_num},'[a-f 0-9]','ignorecase');
    this_default_val=default_vals{reg_num}(index);
    if strcmp(get_param(reg_blk,'RegisterAccess'),'Processor write channel')
        reg_dir='write';
    else
        reg_dir='read';
    end
    reg_info=struct(...
    'name',reg_table_names{reg_num},...
    'data_type','uint32',...
    'vec_length',reg_vec_lengths(reg_num),...
    'offset',this_reg_offset(3:end),...
    'default_val',hex2dec(this_default_val),...
    'direction',reg_dir,...
    'reg_blk',reg_blk...
    );

    if reg_info.vec_length>1
        strobe_reg=reg_info;
        strobe_reg.name=[reg_info.name,'_strobe'];
        strobe_reg.data_type='uint32';
        strobe_reg.offset=dec2hex(2^ceil(log2((reg_info.vec_length)*4))+hex2dec(reg_info.offset),4);
        reg_info=[reg_info,strobe_reg];
    end

end

function basic_regs=set_basic_reg(dut)
    basic_regs=[b_reg('IPCore_Reset','0000'),b_reg('IPCore_Enable','0004')];
    intfs=dut.AXIInterface;
    for n=1:numel(intfs)

        intfs_name=regexprep(intfs{n},'[\W]*','_');


        if contains(intfs_name,'AXI4_Stream_Video')&&contains(intfs_name,'Slave')

            video_slave_regs=get_video_slave_reg(intfs_name,basic_regs(end).offset);
            basic_regs=[basic_regs,video_slave_regs];
        end
    end
    for n=1:numel(intfs)

        intfs_name=regexprep(intfs{n},'[\W]*','_');


        if contains(intfs_name,'AXI4_Stream_0')&&~contains(intfs_name,'Video')&&contains(intfs_name,'Master')



            stream_master_regs=get_stream_master_regs(intfs_name,basic_regs(end).offset);
            basic_regs=[basic_regs,stream_master_regs];
        end
    end
    for n=1:numel(intfs)

        intfs_name=regexprep(intfs{n},'[\W]*','_');


        if contains(intfs_name,'AXI4_Master')

            axi4_master_regs=get_axi4_master_regs(intfs_name,basic_regs(end).offset);
            basic_regs=[basic_regs,axi4_master_regs];
        end
    end



    last_offset=basic_regs(end).offset;

    basic_regs=[basic_regs,b_reg('IPCore_Timestamp',dec2hex(hex2dec(last_offset)+4,4))];
end

function video_slave_regs=get_video_slave_reg(intfs_name,lastOffset)
    video_slave_regs=[b_reg(sprintf('%s_ImageWidth',intfs_name),dec2hex(hex2dec(lastOffset)+4,4))...
    ,b_reg(sprintf('%s_ImageHeight',intfs_name),dec2hex(hex2dec(lastOffset)+8,4))...
    ,b_reg(sprintf('%s_HPorch',intfs_name),dec2hex(hex2dec(lastOffset)+12,4))...
    ,b_reg(sprintf('%s_VPorch',intfs_name),dec2hex(hex2dec(lastOffset)+16,4))...
    ];
end

function stream_master_regs=get_stream_master_regs(intfs_name,lastOffset)
    stream_master_regs=b_reg(sprintf('%s_PacketSize',intfs_name),dec2hex(hex2dec(lastOffset)+4,4));
end

function axi4_master_regs=get_axi4_master_regs(intfs_name,lastOffset)
    if contains(intfs_name,'Read')
        axi4_master_regs=b_reg(sprintf('%s_Rd_BaseAddr',intfs_name(1:13)),dec2hex(hex2dec(lastOffset)+4,4));
    elseif contains(intfs_name,'Write')
        axi4_master_regs=b_reg(sprintf('%s_Wr_BaseAddr',intfs_name(1:13)),dec2hex(hex2dec(lastOffset)+4,4));
    end
end

function reg=b_reg(name,offset)
    reg=struct('name',name,'data_type','uint32','vec_length',1,'offset',offset,'default_val','','direction','','reg_blk','');
end

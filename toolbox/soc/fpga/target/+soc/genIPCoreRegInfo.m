function AXIMasterInfo=genIPCoreRegInfo(socsysinfo,topInfo)

    prjDir=socsysinfo.projectinfo.prj_dir;
    board=socsysinfo.projectinfo.board;
    mdlName=socsysinfo.modelinfo.sys;

    if~isfolder(prjDir)
        mkdir(prjDir);
    end

    if exist(socsysinfo.projectinfo.ipinfofile,'file')
        delete(socsysinfo.projectinfo.ipinfofile);
    end

    AXIMasterInfo={};

    mwips=socsysinfo.ipcoreinfo.mwipcore_info;
    axims=socsysinfo.ipcoreinfo.axi_masters_info;

    dmas=socsysinfo.ipcoreinfo.dma_info;

    vdmas=socsysinfo.ipcoreinfo.vdma_info;

    vdma_fifo=socsysinfo.ipcoreinfo.vdma_fifo_info;

    perf_mon=socsysinfo.ipcoreinfo.perf_mon_info;

    atg=socsysinfo.ipcoreinfo.ATGInfo;

    ctips=socsysinfo.ipcoreinfo.customipcore_info;

    memRegions=[];




    for n=1:numel(dmas)
        thisDMA=dmas(n);
        baseAddr=thisDMA.base_addr;
        if strcmpi(thisDMA.type,'dma_write')
            thisDMAInfo=soc.util.getIPCoreOffset('s2mm_dma',baseAddr);
            thisDMAInfo.bufferSize=str2double(thisDMA.bufferSize);
            thisDMAInfo.type='write';
            AXIMasterInfo.s2mm_dma=thisDMAInfo;
            memRegions.DMAWriteMemRegion=thisDMA.mem_addr;
        else
            thisDMAInfo=soc.util.getIPCoreOffset('mm2s_dma',baseAddr);
            thisDMAInfo.bufferSize=str2double(thisDMA.bufferSize);
            thisDMAInfo.type='read';
            AXIMasterInfo.mm2s_dma=thisDMAInfo;
            memRegions.DMAReadMemRegion=thisDMA.mem_addr;
        end
    end


    for n=1:numel(mwips)
        thisIP=mwips(n);
        baseAddr=thisIP.base_addr;

        thisIPAXIRegs=thisIP.axi_regs;
        thisIPInfo={};
        if~isempty(thisIPAXIRegs)
            for nn=1:numel(thisIPAXIRegs)
                thisIPInfo.(thisIPAXIRegs(nn).name)=(thisIPAXIRegs(nn).offset);
            end
            thisIPInfo=soc.util.getIPCoreOffset('dut',baseAddr,thisIPInfo);
        end

        thisIPAXIRegNames={thisIPAXIRegs.name};
        thisIPAXIRegNames=regexprep(thisIPAXIRegNames,'_[0-9]_','_');
        if any(contains(thisIPAXIRegNames,'AXI4_Stream_Master_PacketSize'))&&isfield(AXIMasterInfo,'s2mm_dma')
            thisIPInfo.packetSize=AXIMasterInfo.s2mm_dma.bufferSize;
        end
        AXIMasterInfo.(sprintf('%s',thisIP.ipcore_name))=thisIPInfo;
    end

    for n=1:numel(axims)
        thisAXIM=axims(n);
        memRegions.(['AXI4MasterMemRegion',num2str(n)])=thisAXIM.mem_addr;
    end


    for n=1:numel(vdmas)
        thisVDMA=vdmas(n);
        baseAddr=thisVDMA.base_addr;
        if strcmpi(thisVDMA.type,'vdma_write')
            thisVDMAInfo=soc.util.getIPCoreOffset('s2mm_vdma',baseAddr);
            thisVDMAInfo.type='write';
            AXIMasterInfo.s2mm_vdma=thisVDMAInfo;
            memRegions.VDMAWriteMemRegion=thisVDMA.mem_addr;
        else
            thisVDMAInfo=soc.util.getIPCoreOffset('mm2s_vdma',baseAddr);
            thisVDMAInfo.type='read';
            AXIMasterInfo.mm2s_vdma=thisVDMAInfo;
            memRegions.VDMAReadMemRegion=thisVDMA.mem_addr;



            frameParam.bytePerPixel=2;
            frameParam.width=thisVDMA.frame_size.width;
            frameParam.height=thisVDMA.frame_size.height;
            frameParam.horizontalPorch=thisVDMA.frame_size.hporch;
            frameParam.verticalPorch=thisVDMA.frame_size.vporch;
            AXIMasterInfo.frameParam=frameParam;
        end
    end


    for n=1:numel(vdma_fifo)
        thisVMDAFIFO=vdma_fifo(n);
        baseAddr=thisVMDAFIFO.base_addr;
        thisVDMAFIFOInfo=soc.util.getIPCoreOffset('vdma_frame_buff',baseAddr);
        if strcmpi(thisVMDAFIFO.type,'vdma_fifo')
            thisVDMAFIFOInfo.type='buffer';
            AXIMasterInfo.vdma_frame_buffer=thisVDMAFIFOInfo;
            memRegions.VDMAFrameBufMemRegion=thisVMDAFIFO.mem_addr;
        end
    end


    for n=1:numel(perf_mon)
        thisPerfMon=perf_mon(n);
        baseAddr=thisPerfMon.base_addr;
        thisPerfMonInfo=soc.util.getIPCoreOffset('perf_mon',baseAddr);
        CoreClkFreq=[thisPerfMon.metric_clock_freq,'e6'];
        thisPerfMonInfo.CoreClkFreq=str2double(CoreClkFreq);
        thisPerfMonInfo.NumSlots=thisPerfMon.num_slots;
        thisPerfMonInfo.AXI4LiteClkFreq=50e6;
        thisPerfMonInfo.Mode=thisPerfMon.mode;
        thisPerfMonInfo.NumRuns=100;
        thisPerfMonInfo.SlotDw=thisPerfMon.slot_dw;
        thisPerfMonInfo.NumDmas=thisPerfMon.NumDmas;
        thisPerfMonInfo.DmaSlotIndex=thisPerfMon.DmaSlotIndex;
        if n==1
            AXIMasterInfo.perf_mon=thisPerfMonInfo;
        else
            AXIMasterInfo.perf_mon=[AXIMasterInfo.perf_mon,thisPerfMonInfo];
        end
    end


    for n=1:numel(atg)
        thisATG=atg(n);
        baseAddr=thisATG.base_addr;
        thisATGInfo=soc.util.getIPCoreOffset('traffic_gen',baseAddr);
        periods=eval(thisATG.periods);
        thisATGInfo.transactionPeriod=periods(2);
        thisATGInfo.ATGClockFreq=str2double(thisATG.clock_freq);
        thisATGInfo.ReadWrite=thisATG.rw_dir;
        thisATGInfo.TotalBurstReq=str2double(get_param(thisATG.blk_name,'TotalBurstRequests'));
        burstSize=ceil(log2(eval(thisATG.mem_width)/8));
        thisATGInfo.BurstSize=burstSize;
        burstLen=ceil(eval(thisATG.bsize)/2^burstSize);
        thisATGInfo.BurstLength=burstLen;
        thisATGInfo.MemAddress=thisATG.mem_addr;
        thisATGInfo.BlockName=thisATG.blk_name;
        if n==1
            AXIMasterInfo.atg=thisATGInfo;
        else
            AXIMasterInfo.atg=[AXIMasterInfo.atg,thisATGInfo];
        end
    end


    for n=1:numel(ctips)
        thisCTIP=ctips(n);
        if strcmpi(thisCTIP.ipcore_name,'HDMIRx')
            for nn=1:numel(thisCTIP.SInterfaces)

                thisSInterface=thisCTIP.SInterfaces(nn);
                if strcmpi(thisSInterface.name,'HDMI/ctrl')
                    baseAddr=thisSInterface.offset;
                    thisVTCInfo=soc.util.getIPCoreOffset('vtc',baseAddr);
                    AXIMasterInfo.vtc=thisVTCInfo;
                elseif contains(thisSInterface.name,'s2mm')
                    baseAddr={};
                    baseAddr{1}=thisSInterface.offset;
                    baseAddr{2}=thisCTIP.SInterfaces(4).offset;
                    thisVDMAFIFOInfo=soc.util.getIPCoreOffset('vdma_frame_buff',baseAddr);
                    thisVDMAFIFOInfo.type='hdmiOut';
                    AXIMasterInfo.vdma_hdmi_out=thisVDMAFIFOInfo;
                    memRegions.VDMAHDMIOutMemRegion='frameParam.HDMIOutMemRegion';
                end
            end
        end
    end

    AXIMasterInfo.memRegions=memRegions;

    save(fullfile(prjDir,[mdlName,'_',board,'_aximaster.mat']),'-struct','AXIMasterInfo');

end



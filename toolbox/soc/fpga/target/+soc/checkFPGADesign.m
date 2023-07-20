



function v=checkFPGADesign(hbuild,socsysinfo,top_info)
    v=hdlvalidatestruct;
    ipcoreinfo=socsysinfo.ipcoreinfo;



    v=[v,check_ddr_freq(hbuild,top_info)];

    v=[v,check_ddr_ic_arbitration(hbuild)];

    v=[v,check_ic_freq(hbuild,ipcoreinfo)];


    v=[v,check_dut_reg_name(ipcoreinfo)];

    v=[v,check_dut_reg_address(ipcoreinfo)];

    v=[v,check_bd_IO_number(hbuild)];

    v=[v,check_ATG_exist(hbuild)];


    v=[v,validateDUTPortNames(ipcoreinfo,hbuild)];

    v=[v,checkJTAGEnable(hbuild)];

    v=[v,checkProcessorEnable(hbuild)];

    v=[v,checkMultiMemCntl(hbuild)];

    v=[v,checkMultiMemCh(hbuild)];




    v=[v,checkAPMNoMemCtrl(hbuild)];

    v=[v,checkNumRFDCBlks(hbuild)];

    v=[v,checkPSSlaveInterfaces(hbuild)];

    v=[v,checkTotalNumIntr(hbuild)];

    v=[v,checkMemoryType(hbuild)];


    for i=1:numel(hbuild.ComponentList)
        if ismethod(hbuild.ComponentList{i},'validateProperties')
            v=[v,hbuild.ComponentList{i}.validateProperties];
        end
    end

    prj_dir=hbuild.ProjectDir;
    if~isfolder(prj_dir)
        mkdir(prj_dir);
    end

    checkfpga_info=v;
    save(fullfile(prj_dir,[socsysinfo.modelinfo.sys,'_checkfpga_info.mat']),'checkfpga_info');
end

function v=check_ddr_freq(hbuild,top_info)
    v=hdlvalidatestruct;


    memCtrlBlkVec=[find_system(hbuild.TopSystemName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','socmemlib/Memory Controller')...
    ,find_system(hbuild.TopSystemName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','socmemlib_internal/Memory Controller')];
    if~isempty(memCtrlBlkVec)
        for i=1:numel(memCtrlBlkVec)
            blkP=hsb.blkcb2.cbutils('GetDialogParams',memCtrlBlkVec{i});
            switch blkP.MemorySelection
            case 'PS memory'
                if~isequal(blkP.ControllerFrequency,hbuild.FPGADesign.AXIMemorySubsystemClockPS)
                    v(end+1)=hdlvalidatestruct(1,message('soc:msgs:checkFpgaDdrFreq'));
                end
            case 'PL memory'
                if~isequal(blkP.ControllerFrequency,hbuild.FPGADesign.AXIMemorySubsystemClockPL)
                    v(end+1)=hdlvalidatestruct(1,message('soc:msgs:checkFpgaDdrFreq'));
                end
            end
        end
    end
end

function v=check_ddr_ic_arbitration(hbuild)
    v=hdlvalidatestruct;


    memCtrlBlkVec=[find_system(hbuild.TopSystemName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','socmemlib/Memory Controller')...
    ,find_system(hbuild.TopSystemName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','socmemlib_internal/Memory Controller')];
    if~isempty(memCtrlBlkVec)
        for i=1:numel(memCtrlBlkVec)
            ICArbitration=get_param(memCtrlBlkVec{i},'ICArbitrationPolicy');
            if~strcmp(ICArbitration,'Round robin')
                v(end+1)=hdlvalidatestruct(1,message('soc:msgs:checkFpgaDdrMigArbitration'));
            end
        end
    end
end

function v=check_ic_freq(hbuild,ipcoreinfo)
    v=hdlvalidatestruct;

    return;
    ic_freq=hbuild.FPGADesign.AXIMemorySubsystemClockPL;

    for i=1:numel(ipcoreinfo.dma_info)
        this_dma=ipcoreinfo.dma_info(i);
        if strcmpi(this_dma.type,'dma_read')&&~strcmpi(soc.util.getValueString(this_dma.dma_blk,'ICClockFrequencyReader'),ic_freq)
            v(end+1)=hdlvalidatestruct(1,message('soc:msgs:checkFpgaIcFreq','Reader',this_dma.dma_blk));
        end
        if strcmpi(this_dma.type,'dma_write')&&~strcmpi(soc.util.getValueString(this_dma.dma_blk,'ICClockFrequencyWriter'),ic_freq)
            v(end+1)=hdlvalidatestruct(1,message('soc:msgs:checkFpgaIcFreq','Writer',this_dma.dma_blk));
        end
    end

    for i=1:numel(ipcoreinfo.vdma_info)
        this_vdma=ipcoreinfo.vdma_info(i);
        if strcmpi(this_vdma.type,'vdma_read')&&~strcmpi(soc.util.getValueString(this_vdma.vdma_blk,'ICClockFrequencyReader'),ic_freq)
            v(end+1)=hdlvalidatestruct(1,message('soc:msgs:checkFpgaIcFreq','Reader',this_vdma.vdma_blk));
        end
        if strcmpi(this_vdma.type,'vdma_write')&&~strcmpi(soc.util.getValueString(this_vdma.vdma_blk,'ICClockFrequencyWriter'),ic_freq)
            v(end+1)=hdlvalidatestruct(1,message('soc:msgs:checkFpgaIcFreq','Writer',this_vdma.vdma_blk));
        end
    end

    for i=1:numel(ipcoreinfo.vdma_fifo_info)
        this_vdma_fifo=ipcoreinfo.vdma_fifo_info(i);
        if~strcmpi(soc.util.getValueString(this_vdma_fifo.vdma_blk,'ICClockFrequencyReader'),ic_freq)
            v(end+1)=hdlvalidatestruct(1,message('soc:msgs:checkFpgaIcFreq','Reader',this_vdma_fifo.vdma_blk));
        end
        if~strcmpi(soc.util.getValueString(this_vdma_fifo.vdma_blk,'ICClockFrequencyWriter'),ic_freq)
            v(end+1)=hdlvalidatestruct(1,message('soc:msgs:checkFpgaIcFreq','Writer',this_vdma_fifo.vdma_blk));
        end
    end
end


function v=check_dut_reg_name(ipcoreinfo)
    v=hdlvalidatestruct;
    for i=1:numel(ipcoreinfo.mwipcore_info)
        this_dut_info=ipcoreinfo.mwipcore_info(i);
        if length(unique({this_dut_info.axi_regs.name}))~=length({this_dut_info.axi_regs.name})
            reg_info='';
            for k=1:numel(this_dut_info.axi_regs)
                reg_info=[reg_info,sprintf('                       Block = ''%s'', name = ''%s''\n',this_dut_info.axi_regs(k).reg_blk,this_dut_info.axi_regs(k).name)];
            end
            v(end+1)=hdlvalidatestruct(1,message('soc:msgs:checkFpgaDutRegName',this_dut_info.blk_name,reg_info));
        end
    end
end

function v=check_dut_reg_address(ipcoreinfo)


    function[lastElemAddr,strobeAddr]=l_calcVecAddr(start,length,REG_SIZE)

        lastElemAddr=start+(length*REG_SIZE)-REG_SIZE;
        alignedBlockSize=pow2(ceil(log2(length)))*REG_SIZE;
        strobeAddr=start+alignedBlockSize;
    end
    function regarray=l_addVecEntries(reg,lastElemAddr,regarray)
        rle=reg;
        rle.name=[reg.name,'_lastelement'];
        rle.vec_length=1;
        rle.offset=dec2hex(lastElemAddr,4);
        regarray(end+1)=rle;
    end

    v=hdlvalidatestruct;
    for i=1:numel(ipcoreinfo.mwipcore_info)
        this_dut_info=ipcoreinfo.mwipcore_info(i);













        REG_SIZE=4;


        autoregs=this_dut_info.axi_regs;
        currAddr=256;
        isStrobeReg=false;
        for k=1:numel(autoregs)
            r=autoregs(k);
            if hex2dec(r.offset)>=hex2dec('100')
                r.offset=dec2hex(currAddr,4);
                if r.vec_length>1&&isStrobeReg==false
                    [lastElemAddr,strobeAddr]=l_calcVecAddr(currAddr,r.vec_length,REG_SIZE);

                    currAddr=strobeAddr;
                    isStrobeReg=true;
                else
                    currAddr=currAddr+REG_SIZE;
                    isStrobeReg=false;
                end
                autoregs(k)=r;
            end
        end


        takenAddr=[];
        specregs=this_dut_info.axi_regs;
        numregs=length(specregs);
        regnames=cell(1,numregs);
        regaddrs=zeros([numregs,3]);
        isStrobeReg=false;
        for k=1:numel(specregs)
            if isStrobeReg
                isStrobeReg=false;
            else
                r=specregs(k);
                currAddr=hex2dec(r.offset);
                regnames(k)={sprintf('%3d : %s',k,r.name)};
                if r.vec_length>1&&isStrobeReg==false
                    [lastElemAddr,strobeAddr]=l_calcVecAddr(currAddr,r.vec_length,REG_SIZE);
                    specregs=l_addVecEntries(r,lastElemAddr,specregs);
                    takenAddr=[takenAddr,(currAddr:strobeAddr)];
                    regaddrs(k,:)=[currAddr,0,strobeAddr];
                    isStrobeReg=true;
                else
                    takenAddr=[takenAddr,currAddr];
                    regaddrs(k,:)=[currAddr,0,currAddr];
                end
            end
        end

        if length(unique(takenAddr))~=length(takenAddr)
            specRegsTable=struct2table(specregs(:));
            specRegsSorted=sortrows(specRegsTable,'offset');
            specRegInfo=evalc('disp(specRegsSorted)');

            figName='Register Memory Map';
            fh=findobj('Type','Figure','Name',figName);
            if isempty(fh)
                fh=figure('Name',figName);
            end
            errorbar((1:numregs),regaddrs(:,1),regaddrs(:,2),regaddrs(:,3)-regaddrs(:,1),'o');
            ylabel('Address');
            xlabel('Register #');
            title('Register Memory Map');
            legend(sprintf('%s\n',regnames{:}),'Location','northeastoutside');

            autoRegsTable=struct2table(autoregs(:));
            autoRegsSorted=sortrows(autoRegsTable,{'reg_blk','name'});
            autoRegInfo=evalc('disp(autoRegsSorted)');

            v(end+1)=hdlvalidatestruct(1,message('soc:msgs:checkFpgaDutRegAddress',this_dut_info.blk_name,specRegInfo,autoRegInfo));
        end
    end
end


function v=check_bd_IO_number(hbuild)
    v=hdlvalidatestruct;
    pb_blk=find_system(hbuild.TopSystemName,'SearchDepth',1,'ReferenceBlock','hwlogiciolib/Push Button');
    ds_blk=find_system(hbuild.TopSystemName,'SearchDepth',1,'ReferenceBlock','hwlogiciolib/DIP Switch');
    led_blk=find_system(hbuild.TopSystemName,'SearchDepth',1,'ReferenceBlock','hwlogiciolib/LED');
    if numel(pb_blk)>1
        v(end+1)=hdlvalidatestruct(1,message('soc:msgs:checkBdIOBlkNumber','Push Button',hbuild.TopSystemName));
    end
    if numel(ds_blk)>1
        v(end+1)=hdlvalidatestruct(1,message('soc:msgs:checkBdIOBlkNumber','DIP Switch',hbuild.TopSystemName));
    end
    if numel(led_blk)>1
        v(end+1)=hdlvalidatestruct(1,message('soc:msgs:checkBdIOBlkNumber','LED',hbuild.TopSystemName));
    end
end



function[failStr]=l_getMsgString(input)
    num=length(input);
    failStr='';
    blocks=input(1).block;
    sep=', ';
    if num<=2
        sep=' ';
    end
    for nn=1:num
        if nn==num
            failStr=[failStr,'and ',blocks{nn}];%#ok<AGROW>
        else
            failStr=[failStr,blocks{nn},sep];%#ok<AGROW>
        end
    end
end

function v=check_ATG_exist(hbuild)
    sys=hbuild.TopSystemName;
    v=hdlvalidatestruct;
    fpgaModelBlock=soc.util.getHSBSubsystem(sys);
    TrafficGenerator=find_system(sys,'searchdepth',1,'ReferenceBlock','socmemlib/Memory Traffic Generator');
    if isempty(TrafficGenerator)&&isempty(fpgaModelBlock)
        v(end+1)=hdlvalidatestruct(1,message('soc:msgs:checkGenAXITrafficGeneratorIfNoFPGAModel'));
    end
end


function v=validateDUTPortNames(ipcoreinfo,hbuild)
    v=hdlvalidatestruct;
    targetLanguage=hdlget_param(hbuild.SystemName,'TargetLanguage');
    rsvdWords=getReservedWords(targetLanguage);
    intfInfo=hbuild.IntfInfo;
    for i=1:numel(ipcoreinfo.mwipcore_info)
        this_blk=ipcoreinfo.mwipcore_info(i).blk_name;
        inp=find_system(this_blk,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Inport');
        outp=find_system(this_blk,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Outport');
        all_port=[inp;outp];

        extPorts={};
        for j=1:numel(all_port)
            thisPort=all_port{j};
            thisPortIntfInfo=intfInfo(thisPort);
            if strcmp(thisPortIntfInfo.interface,'External Port')
                extPorts{end+1}=thisPort;%#ok<AGROW>
            end
        end

        extPortsNames=get_param(extPorts,'portname');

        for j=1:numel(extPortsNames)
            thisPortName=extPortsNames{j};
            indx=strcmpi(thisPortName,extPortsNames(j+1:end));
            indxPos=find(indx);
            if nnz(indx)~=0
                v(end+1)=hdlvalidatestruct(1,message('soc:msgs:DUTWithSamePortNames',this_blk,thisPortName,extPortsNames{indxPos(1)+j}));
            end

            if nnz((cellfun(@(x)strcmpi(x,thisPortName),rsvdWords)))~=0
                v(end+1)=hdlvalidatestruct(1,message('soc:msgs:DUTWithRSRVDPortNames',this_blk,extPortsNames{j}));
            end

            if any(strcmp(thisPortName(1),[{' ','_'},strsplit(num2str(0:9))]))...
                ||any(strcmp(thisPortName(end),{' ','_'}))
                v(end+1)=hdlvalidatestruct(1,message('soc:msgs:DUTPortNameStartsWithInvalidChar',this_blk,extPortsNames{j}));
            end
        end
    end
end


function v=checkJTAGEnable(hbuild)
    v=hdlvalidatestruct;

    if any(cellfun(@(x)isa(x,'soc.xilcomp.ATG'),hbuild.ComponentList))||...
        any(cellfun(@(x)isa(x,'soc.intelcomp.ATG'),hbuild.ComponentList))||...
        any(cellfun(@(x)isa(x,'soc.xilcomp.APM'),hbuild.ComponentList))||...
        any(cellfun(@(x)isa(x,'soc.intelcomp.APM'),hbuild.ComponentList))
        if~any(cellfun(@(x)isa(x,'soc.xilcomp.JTAGMaster'),hbuild.ComponentList))&&...
            ~any(cellfun(@(x)isa(x,'soc.intelcomp.JTAGMaster'),hbuild.ComponentList))
            v(end+1)=hdlvalidatestruct(1,message('soc:msgs:NoJTAGForATGAPMHDMI'));
        end
    end
end

function v=checkProcessorEnable(hbuild)
    v=hdlvalidatestruct;

    if any(cellfun(@(x)isa(x,'soc.xilcomp.HDMIRx'),hbuild.FMCIO))
        if isempty(hbuild.PS7)
            v(end+1)=hdlvalidatestruct(1,message('soc:msgs:NoProcessorForHDMI'));
        end
    end

    if any(cellfun(@(x)isa(x,'soc.xilcomp.RFDataConverter'),hbuild.FMCIO))&&...
        isempty(hbuild.PS7)
        v(end+1)=hdlvalidatestruct(1,message('soc:msgs:NoProcessorForRFDC'));
    end
end

function v=checkMultiMemCntl(hbuild)
    v=hdlvalidatestruct;



    memCtrlBlks=find_system(hbuild.TopSystemName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'referenceblock','socmemlib/Memory Controller');

    if numel(memCtrlBlks)>2
        v(end+1)=hdlvalidatestruct(1,message('soc:msgs:MultiMemCtrlBlksLimit'));
    end

    if numel(memCtrlBlks)>1
        if strcmpi(get_param(memCtrlBlks{1},'MemorySelection'),get_param(memCtrlBlks{2},'MemorySelection'))
            v(end+1)=hdlvalidatestruct(1,message('soc:msgs:MultiMemCtrlBlksSelection'));
        end
    end
end


function v=checkMultiMemCh(hbuild)
    v=hdlvalidatestruct;



    memChBlks=[find_system(hbuild.TopSystemName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'referenceblock','socmemlib/Memory Channel');...
    find_system(hbuild.TopSystemName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'referenceblock','socmemlib/AXI4-Stream to Software');
    find_system(hbuild.TopSystemName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'referenceblock','socmemlib/Software to AXI4-Stream');
    find_system(hbuild.TopSystemName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'referenceblock','socmemlib/AXI4 Random Access Memory');
    find_system(hbuild.TopSystemName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'referenceblock','socmemlib/AXI4 Video Frame Buffer')];
    chTypes=get_param(memChBlks,'ChannelType');
    dmasInSimFPGA=strcmp(chTypes,'AXI4-Stream FIFO');
    dmasRxInSimProc=strcmp(chTypes,'AXI4-Stream to Software via DMA');
    dmasTxInSimProc=strcmp(chTypes,'Software to AXI4-Stream via DMA');
    dmasInSim=[dmasInSimFPGA,dmasRxInSimProc,dmasTxInSimProc];
    vdmasInSim=strcmp(chTypes,'AXI4-Stream Video FIFO');
    frmBuffInSim=strcmp(chTypes,'AXI4-Stream Video Frame Buffer');

    dmasInGen=cellfun(@(x)contains(class(x),'DMA')&&~contains(class(x),'VDMA'),hbuild.ComponentList);
    vdmasInGen=cellfun(@(x)contains(class(x),'VDMA')&&~contains(class(x),'FrameBuffer'),hbuild.ComponentList);
    frmBuffInGen=cellfun(@(x)contains(class(x),'FrameBuffer'),hbuild.ComponentList);


    if nnz(dmasInSim)~=nnz(dmasInGen)||...
        nnz(vdmasInSim)~=nnz(vdmasInGen)||...
        nnz(frmBuffInSim)~=nnz(frmBuffInGen)
        v(end+1)=hdlvalidatestruct(1,message('soc:msgs:MultiMemChBlks'));
    end
end

function v=checkAPMNoMemCtrl(hbuild)
    v=hdlvalidatestruct;

    hasAPM=soc.internal.hasAPM(hbuild.TopSystemName);


    memCntlBlks=[find_system(hbuild.TopSystemName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'referenceblock','socmemlib/Memory Controller');...
    find_system(hbuild.TopSystemName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'referenceblock','socmemlib_internal/Memory Controller');...
    find_system(hbuild.TopSystemName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'referenceblock','socmemlib/AXI4-Stream to Software');...
    find_system(hbuild.TopSystemName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'referenceblock','socmemlib/Software to AXI4-Stream');...
    find_system(hbuild.TopSystemName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'referenceblock','socmemlib/AXI4 Random Access Memory');...
    find_system(hbuild.TopSystemName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'referenceblock','socmemlib/AXI4 Video Frame Buffer')];
    ATGBlks=find_system(hbuild.TopSystemName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'referenceblock','socmemlib/Memory Traffic Generator');
    memCntlBlks=[memCntlBlks;ATGBlks(strcmpi(get_param(ATGBlks,'ShowMemoryControllerPorts'),'off'))];

    if hasAPM&&isempty(memCntlBlks)
        v(end+1)=hdlvalidatestruct(1,message('soc:msgs:APMNoMemCtrl'));
    end
end

function v=checkNumRFDCBlks(hbuild)
    v=hdlvalidatestruct;

    rfDCBlks=find_system(hbuild.TopSystemName,'SearchDepth',1,'ReferenceBlock','xilinxrfsoclib/RF Data Converter');
    if numel(rfDCBlks)>1
        v(end+1)=hdlvalidatestruct(1,message('soc:msgs:checkNumRFDCBlks',hbuild.TopSystemName));
    end
end

function v=checkPSSlaveInterfaces(hbuild)
    v=hdlvalidatestruct;
    if soc.internal.isCustomHWBoard(hbuild.Board.Name)
        if~isempty(hbuild.PS7)

            numMasters=sum(arrayfun(@(x)(strcmpi(x.usage,'mem')),hbuild.Interconnect.master,'UniformOutput',true));
            numSlaves=numel(hbuild.PS7.AXI4Slave);
            if numSlaves<numMasters
                v(end+1)=hdlvalidatestruct(1,message('soc:msgs:checkPSSlaveInterfaces',numSlaves,numMasters));
            end
        end
    end
end

function v=checkTotalNumIntr(hbuild)
    v=hdlvalidatestruct;
    if~isempty(hbuild.PS7)||~isempty(hbuild.HPS)
        totalIntr=numel(hbuild.Interrupt);
        cs=getActiveConfigSet(hbuild.TopSystemName);
        maxLimit=codertarget.interrupts.getFPGAInterupts(cs);
        if totalIntr>maxLimit
            v(end+1)=hdlvalidatestruct(1,message('soc:msgs:NumIntrMaxLimit',maxLimit));
        end
    end
end

function v=checkMemoryType(hbuild)










    v=hdlvalidatestruct;
    for i=1:numel(hbuild.ComponentList)
        thisComp=hbuild.ComponentList{i};
        if isa(thisComp,'soc.xilcomp.DMARead')||...
            isa(thisComp,'soc.xilcomp.DMAWrite')||...
            isa(thisComp,'soc.intelcomp.DMAWrite')||...
            isa(thisComp,'soc.intelcomp.DMARead')
            chType=get_param(thisComp.BlkName,'ChannelType');
            if any(strcmpi(chType,{'AXI4-Stream to Software via DMA',...
                'Software to AXI4-Stream via DMA'}))
                if~strcmpi(thisComp.Configuration.mem_type,'memPS')
                    v(end+1)=hdlvalidatestruct(1,message('soc:msgs:UnsupportedMemType',thisComp.BlkName,chType,'PS memory'));%#ok<*AGROW> 
                end
            else
                if~strcmpi(thisComp.Configuration.mem_type,'memPL')
                    v(end+1)=hdlvalidatestruct(1,message('soc:msgs:UnsupportedMemType',thisComp.BlkName,chType,'PL memory'));%#ok<*AGROW> 
                end
            end
        elseif isa(thisComp,'soc.xilcomp.VDMARead')||...
            isa(thisComp,'soc.xilcomp.VDMAWrite')||...
            isa(thisComp,'soc.xilcomp.VDMAFrameBuffer')||...
            isa(thisComp,'soc.xilcomp.AXIM')||...
            isa(thisComp,'soc.intelcomp.AXIM')
            if~strcmpi(thisComp.Configuration.mem_type,'memPL')
                chType=get_param(thisComp.BlkName,'ChannelType');
                v(end+1)=hdlvalidatestruct(1,message('soc:msgs:UnsupportedMemType',thisComp.BlkName,chType,'PL memory'));%#ok<*AGROW> 
            end
        elseif isa(thisComp,'soc.xilcomp.ATG')||...
            isa(thisComp,'soc.intelcomp.ATG')
            if~strcmpi(thisComp.Configuration.mem_type,'memPL')
                v(end+1)=hdlvalidatestruct(1,message('soc:msgs:UnsupportedMemTypeATG',thisComp.BlkName,'PL memory'));%#ok<*AGROW> 
            end
        end
    end
end

function rsvdWords=getReservedWords(targetLanguage)
    switch targetLanguage
    case 'Verilog'
        rsvdWords={
        "always","and","assign","automatic","begin","buf","bufif0","bufif1",...
        "case","casex","casez","cell","cmos","config","deassign","default",...
        "defparam","design","disable","edge","else","end","endcase","endconfig",...
        "endfunction","endgenerate","endmodule","endprimitive","endspecify","endtable",...
        "endtask","event","for","force","forever","fork","function","generate",...
        "genvar","highz0","highz1","if","ifnone","incdir","include","initial",...
        "inout","input","instance","integer","join","large","liblist","library",...
        "localparam","macromodule","medium","module","nand","negedge","nmos","nor",...
        "noshowcancelled","not","notif0","notif1","or","output","parameter","pmos",...
        "posedge","primitive","pull0","pull1","pulldown","pullup",...
        "pulsestyle_onevent","pulsestyle_ondetect","rcmos","real","realtime","reg",...
        "release","repeat","rnmos","rpmos","rtran","rtranif0","rtranif1","scalared",...
        "showcancelled","signed","small","specify","specparam","strong0","strong1",...
        "supply0","supply1","table","task","time","tran","tranif0","tranif1",...
        "tri","tri0","tri1","triand","trior","trireg","unsigned","use","uwire",...
        "vectored","wait","wand","weak0","weak1","while","wire","wor","xnor","xor",...
"0"
        };%#ok<*CLARRSTR>
    case 'VHDL'
        rsvdWords={
        "abs","access","after","alias","all","and","architecture","array",...
        "assert","attribute","begin","block","body","buffer","bus","case",...
        "component","configuration","constant","disconnect","downto","else",...
        "elsif","end","entity","exit","file","for","function","generate",...
        "generic","group","guarded","if","impure","in","inertial","inout","is",...
        "label","library","linkage","literal","loop","map","mod","nand","new",...
        "next","nor","not","null","of","on","open","or","others","out",...
        "package","port","postponed","procedure","process","pure","range",...
        "record","register","reject","rem","report","return","rol","ror",...
        "select","severity","signal","shared","sla","sll","sra","srl","subtype",...
        "then","to","transport","type","unaffected","units","until","use",...
        "variable","wait","when","while","with","xnor","xor","real","integer",...
        "time","std_ulogic","std_ulogic_vector","resolved","std_logic",...
        "std_logic_vector","X01","X01Z","UX01","UX01Z","To_bit","To_bitvector",...
        "To_StdULogic","To_StdLogicVector","To_StdULogicVector","To_X01","To_X01Z",...
        "To_UX01","rising_edge","falling_edge","Is_X","stdlogic_1d",...
        "stdlogic_table","resolution_table","and_table","or_table","xor_table",...
        "not_table","logic_x01_table","logic_x01z_table","logic_ux01_table",...
        "cvt_to_x01","cvt_to_x01z","cvt_to_ux01","signed","unsigned","shift_left",...
        "shift_right","rotate_left","rotate_right","resize","to_integer",...
        "to_unsigned","to_signed","std_match","TO_01","NAU","NAS","NO_WARNING",...
        "boolean","false","true","bit","character","severity_level","delay_length",...
        "now","natural","positive","string","bit_vector","file_open_kind",...
        "file_open_status","foreign","note","warning","error","failure",...
        "to_hex","isequal","endfile","hread","line","read","read_mode",...
        "readline","text","0",...
        };
    end
end

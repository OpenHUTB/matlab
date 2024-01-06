classdef MemoryMapInfo<handle

    properties(SetAccess=private)
boardName
FPGAVendor
FPGAFamily

mmap

        currMemPSAddrPtr=uint64(0);
        currMemPLAddrPtr=uint64(0);
        currRegAddrPtr=uint64(0);
        defaultRange={'64','K'};
        defaultRegOffset='0x100';
dut
dutMap
        memPSChBlks={};
        memPLChBlks={};
        atgBlks={};
        controllerInfo={};
        implicitInfo={};
        hsbSubsystem=[];
mdlH
FPGADesign
        isFixedMemMap=false;
        DUTFixedBaseAddr='0x00000000';
    end

    properties(Constant)
        compAD9361IIC='AD9361/S_AXI_IIC';
        compAD9361AXI='AD9361/S_AXI_AD9361';
        compHDMIAXI='HDMI/S_AXI';
        compHDMICtrl='HDMI/ctrl';
        compAXIS2MMDMAC='axi_vdma_s2mm_2/s_axi';
        compAXIMM2SDMAC='axi_vdma_mm2s_2/s_axi';
        compRFDCAXI='RFDataConverter/s_axi';
    end

    methods
        function obj=MemoryMapInfo(cs)
            obj.mdlH=cs.getModel;
            obj.FPGADesign=codertarget.data.getParameterValue(cs,'FPGADesign');
            obj.boardName=codertarget.data.getParameterValue(cs,'TargetHardware');
        end

        function setMemMap(obj,map)
            obj.mmap=map;



            map.controllerInfo=obj.controllerInfo;

        end

        function setBoardParams(obj)
            switch obj.boardName
            case{'ZedBoard','Xilinx Zynq ZC706 evaluation kit'}
                obj.FPGAVendor='Xilinx';
                obj.FPGAFamily='Zynq';
            case{'Xilinx Zynq UltraScale+ MPSoC ZCU102 Evaluation Kit'}
                obj.FPGAVendor='Xilinx';
                obj.FPGAFamily='Zynq UltraScale+';
            case{'Artix-7 35T Arty FPGA evaluation kit'}
                obj.FPGAVendor='Xilinx';
                obj.FPGAFamily='Artix7';
            case{'Xilinx Kintex-7 KC705 development board'}
                obj.FPGAVendor='Xilinx';
                obj.FPGAFamily='Kintex7';
            case{'Altera Cyclone V SoC development kit'}
                obj.FPGAVendor='Intel';
                obj.FPGAFamily='Cyclone V';
            case{'Altera Arria 10 SoC development kit'}
                obj.FPGAVendor='Intel';
                obj.FPGAFamily='Arria 10';
            case codertarget.internal.getCustomHardwareBoardNamesForSoC
                fobs=soc.internal.getCustomBoardParams(obj.boardName);
                obj.FPGAVendor=fobs.fdevObj.FPGAVendor;
                obj.FPGAFamily=fobs.fdevObj.FPGAFamily;
            otherwise
                obj.FPGAVendor='Unknown';
                obj.FPGAFamily='Unknown';
            end

        end

        function setControllerParams(obj)
            obj.controllerInfo=soc.memmap.MemController(obj);
        end

        function[isValid,errStr]=checkMemoryMap(obj,varargin)
            [isValid,errStr]=obj.mmap.checkMemoryMap(varargin{:});
        end

        function resetMap(obj)
            obj.paramReset;
            obj.scrapeModel(getfullname(obj.mdlH));
            obj.genAutoMap;
        end

        function reconcileMap(obj,newAutoMap)


            numEntries=length(obj.mmap.map);
            toKeepInCurr=zeros([numEntries,1],'logical');
            highestAddress=zeros([2,1]);
            if~newAutoMap.isFixedMemMap
                for ii=1:numEntries
                    currEntry=obj.mmap.map(ii);
                    autoEntry=findobj(newAutoMap.map,'name',currEntry.name,'type',currEntry.type);
                    if~isempty(autoEntry)
                        toKeepInCurr(ii)=true;
                        currEntry.reconcile(autoEntry);
                        highestAddress=l_trackHighestAddress(highestAddress,currEntry);
                        obj.mmap.map(ii)=currEntry;
                    end
                end
            end
            obj.mmap.map=obj.mmap.map(toKeepInCurr);
            obj.mmap.isFixedMemMap=newAutoMap.isFixedMemMap;

            numEntries=length(newAutoMap.map);
            for ii=1:numEntries
                autoEntry=newAutoMap.map(ii);
                currEntry=findobj(obj.mmap.map,'name',autoEntry.name);
                if isempty(currEntry)

                    newEntry=autoEntry;
                    if strcmp(autoEntry.name,'VDMA Frame Buffer Read')
                        frmBuffObj=findobj(obj.mmap.map,'name','VDMA Frame Buffer Write');
                        newEntry.baseAddr=l_dec2hexAddr(l_hex2decAddr(frmBuffObj.baseAddr)+l_str2decRange(obj.defaultRange));
                    elseif newAutoMap.isFixedMemMap
                        newEntry.baseAddr=autoEntry.baseAddr;
                    else
                        newEntry.baseAddr=l_dec2hexAddr(l_calcNextAlignedAddress(highestAddress,newEntry.type));
                    end
                    highestAddress=l_trackHighestAddress(highestAddress,newEntry);
                    obj.mmap.map=[obj.mmap.map;newEntry];
                end
            end
            tempObj=findobj(obj.mmap.map,'name','VDMA Frame Buffer Read');
            if~isempty(tempObj)
                indx=find(strcmp(tempObj.baseAddr,{obj.mmap.map.baseAddr}),2);
                if length(indx)==2
                    for i=1:2
                        if~strcmp(obj.mmap.map(indx(i)).name,'VDMA Frame Buffer Read')
                            obj.mmap.map(indx(i)).baseAddr=l_dec2hexAddr(l_calcNextAlignedAddress(highestAddress,obj.mmap.map(indx(i)).type));
                            highestAddress=l_trackHighestAddress(highestAddress,obj.mmap.map(indx(i)));
                        end
                    end
                end
            end
        end

        function paramReset(obj)
            obj.implicitInfo={};
            obj.memPSChBlks={};
            obj.memPLChBlks={};
            obj.atgBlks={};
        end

        function scrapeModel(obj,mdl)
            if ishandle(mdl),mdl=getfullname(mdl);end


            l_checkMemBlockOnTop(mdl);


            libblocks=[];
            blocknames=[];
            obj.hsbSubsystem=soc.util.getHSBSubsystem(mdl);
            if~isempty(obj.hsbSubsystem)
                hsbMdlRef=get_param(obj.hsbSubsystem,'ModelName');
                obj.dut=soc.util.getDUT(hsbMdlRef);


                [obj.isFixedMemMap,rdInfo]=soc.internal.getReferenceDesignInfo(hsbMdlRef);
            end

            if obj.isFixedMemMap
                if numel(obj.dut)==1
                    obj.DUTFixedBaseAddr=rdInfo.DUTBaseAddress;
                else

                end
            else
                allblocks=libinfo(mdl,'searchdepth',1);
                for i=1:length(allblocks)
                    if(strcmp(allblocks(i).Library,'hsblib_beta2')||strcmp(allblocks(i).Library,'socregisterchanneli2clib')||strcmp(allblocks(i).Library,'socmemlib'))
                        libblocks=[libblocks;allblocks(i)];
                    end
                end
                for i=1:length(libblocks)
                    blocknames{i}=libblocks(i).Block;
                end

                if~isempty(blocknames)


                    memChBlks=[find_system(mdl,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','socmemlib/Memory Channel');...
                    find_system(mdl,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','socmemlib/AXI4-Stream to Software');...
                    find_system(mdl,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','socmemlib/Software to AXI4-Stream');...
                    find_system(mdl,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','socmemlib/AXI4 Random Access Memory');...
                    find_system(mdl,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','socmemlib/AXI4 Video Frame Buffer')];
                    for i=1:numel(memChBlks)
                        mem_type=l_getMemChBlkType(memChBlks{i});
                        switch mem_type
                        case 'memPS'
                            obj.memPSChBlks=[obj.memPSChBlks,memChBlks{i}];
                        case 'memPL'
                            obj.memPLChBlks=[obj.memPLChBlks,memChBlks{i}];
                        end
                    end



                    obj.atgBlks=find_system(mdl,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','socmemlib/Memory Traffic Generator');
                end
            end
            obj.setBoardParams;
            obj.setControllerParams;
        end

        function genAutoMap(obj)
            obj.mmap=soc.memmap.MemoryMap();
            obj.mmap.controllerInfo=obj.controllerInfo;

            obj.currMemPSAddrPtr=l_hex2decAddr(obj.controllerInfo.memPSBaseAddr);
            obj.currMemPLAddrPtr=l_hex2decAddr(obj.controllerInfo.memPLBaseAddr);
            obj.currRegAddrPtr=l_hex2decAddr(obj.controllerInfo.regBaseAddr);


            if~isempty(obj.memPSChBlks)
                for i=1:numel(obj.memPSChBlks)
                    mblock=obj.memPSChBlks{i};
                    rangeStr=get_param(mblock,'MRRegionSize');
                    AlignedRange=l_get4KAlignedRange({rangeStr,''});
                    obj.mmap.map=[obj.mmap.map;soc.memmap.MapParams(soc.memmap.MemUtil.strDevPSMemory,get_param(mblock,'Name'),l_dec2hexAddr(obj.currMemPSAddrPtr),AlignedRange,mblock)];
                    obj.currMemPSAddrPtr=obj.currMemPSAddrPtr+l_str2decRange(AlignedRange);
                end
            end
            if~isempty(obj.memPLChBlks)
                for i=1:numel(obj.memPLChBlks)
                    mblock=obj.memPLChBlks{i};
                    rangeStr=get_param(mblock,'MRRegionSize');
                    AlignedRange=l_get4KAlignedRange({rangeStr,''});
                    obj.mmap.map=[obj.mmap.map;soc.memmap.MapParams(soc.memmap.MemUtil.strDevPLMemory,get_param(mblock,'Name'),l_dec2hexAddr(obj.currMemPLAddrPtr),AlignedRange,mblock)];
                    obj.currMemPLAddrPtr=obj.currMemPLAddrPtr+l_str2decRange(AlignedRange);
                end
            end

            if~isempty(obj.hsbSubsystem)
                hsbMdlRef=get_param(obj.hsbSubsystem,'ModelName');
                obj.mapRegsWithDUT(obj.hsbSubsystem);



                fpgablocks=[libinfo(hsbMdlRef,'searchdepth',1);libinfo(bdroot(obj.hsbSubsystem),'searchdepth',1)];

                if any(strcmp({fpgablocks.ReferenceBlock},'xilinxsocad9361lib/AD9361Rx'))
                    obj.mapSDRImplicitIP;
                end

                if any(strcmp({fpgablocks.ReferenceBlock},'xilinxsocvisionlib/HDMI Rx'))
                    obj.mapVisionImplicitIP;
                end

                if any(strcmp({fpgablocks.ReferenceBlock},'xilinxrfsoclib/RF Data Converter'))
                    obj.mapRFDCImplicitIP;
                end
                obj.genAutoDUT;



                obj.genAutoCustomIP(hsbMdlRef);
            end

            if~isempty(obj.atgBlks)
                obj.genAutoATG;
            end
            if~obj.isFixedMemMap
                obj.genAutoImplicitIP;
            end

            [isValid,errStr]=obj.checkMemoryMap();%#ok<ASGLU>



            obj.mmap.isAutoMap=true;
            obj.mmap.isFixedMemMap=obj.isFixedMemMap;
        end

        function genAutoATG(obj)
            for i=1:numel(obj.atgBlks)
                obj.mmap.map=[obj.mmap.map;soc.memmap.MapParams(soc.memmap.MemUtil.strDevImplicit,get_param(obj.atgBlks{i},'name'),l_dec2hexAddr(obj.currRegAddrPtr),obj.defaultRange)];
                obj.currRegAddrPtr=obj.currRegAddrPtr+l_str2decRange(obj.defaultRange);
            end
        end

        function genAutoDUT(obj)


            map_dut2reg=obj.dutMap;
            dutBlks={};
            dutBlksTunableParams={};
            dutBlksTunableParamDims={};
            for i=1:numel(obj.dut)
                thisDUT=obj.dut{i};

                [tunableParams,tunableParamDims]=soc.internal.getTunableParameter(thisDUT);
                regWrite={};
                regRead={};
                if obj.isFixedMemMap
                    [regWrite,regRead]=soc.internal.getDUTRegPorts(thisDUT,bdroot(obj.hsbSubsystem));
                end
                if isKey(map_dut2reg,thisDUT)||...
                    numel(tunableParams)>0||...
                    numel(regWrite)>0||numel(regRead)>0
                    dutBlks=[dutBlks,thisDUT];
                    dutBlksTunableParams=[dutBlksTunableParams,{tunableParams}];
                    dutBlksTunableParamDims=[dutBlksTunableParamDims,{tunableParamDims}];

                end
            end

            for i=1:numel(dutBlks)



                regs=soc.memmap.IPCoreRegParams('HDL Coder registers','0x0000 - 0x00FF','N/A','Reserved',true);
                regvl={};
                regtype={};
                numregs=0;
                regnames={};



                if obj.isFixedMemMap
                    [regInPorts,regOutPorts,inPortDims,outPortDims]=soc.internal.getDUTRegPorts(dutBlks{i},bdroot(obj.hsbSubsystem));
                    for ii=1:numel(regInPorts)
                        regnames=[regnames,{get_param(regInPorts{ii},'name')}];%#ok<*AGROW> 
                        regvl=[regvl,inPortDims(ii)];
                        regtype=[regtype,{'Processor write channel'}];
                    end

                    for ii=1:numel(regOutPorts)
                        regnames=[regnames,{get_param(regOutPorts{ii},'name')}];
                        regvl=[regvl,outPortDims(ii)];
                        regtype=[regtype,{'Processor read channel'}];
                    end
                    numregs=numregs+numel(regOutPorts)+numel(regInPorts);
                end


                if isKey(map_dut2reg,dutBlks{i})
                    regBlks=map_dut2reg(dutBlks{i});
                    for j=1:numel(regBlks)
                        block=regBlks{j};
                        currregs=str2double(get_param(block,'NumRegisters'));
                        numregs=numregs+currregs;
                        regnames=[regnames,eval(get_param(block,'regtablenames'))];
                        if strcmpi(get_param(block,'ReferenceBlock'),'socmemlib/Register Channel')
                            regvl=[regvl,eval(get_param(block,'regtablevectorsizes'))];
                            regtypeStr=evalin('base',get_param(block,'regTablerw'));
                            for ii=1:numel(regtypeStr)
                                if strcmpi(regtypeStr(ii),'w')||strcmpi(regtypeStr(ii),'Write')
                                    regtype=[regtype,{'Processor write channel'}];
                                elseif strcmpi(regtypeStr(ii),'r')||strcmpi(regtypeStr(ii),'Read')
                                    regtype=[regtype,{'Processor read channel'}];
                                else
                                    error('%s: Invalid register type: %s',getfullname(block),regtypeStr{ii});
                                end
                            end
                        else
                            regvl=[regvl,eval(get_param(block,'regtablevectorlengths'))];
                            regtype=[regtype,repmat({get_param(block,'registeraccess')},1,currregs)];
                        end
                    end
                end

                tunableParams=dutBlksTunableParams{i};
                tunableParamDims=dutBlksTunableParamDims{i};
                for kk=1:numel(tunableParams)
                    regnames=[regnames,tunableParams(kk)];
                    regvl=[regvl,{num2str(prod(tunableParamDims{kk}))}];
                    regtype=[regtype,{'Processor write channel'}];
                end
                regoffsets=obj.genRegOffsets(regvl);
                numregs=numregs+numel(tunableParams);
                for k=1:numregs
                    regs=[regs;soc.memmap.IPCoreRegParams('',get_param(dutBlks{i},'Name'),regnames{k},regoffsets{k},regvl{k},regtype{k},false)];
                end
                if obj.isFixedMemMap
                    obj.mmap.map=[obj.mmap.map;soc.memmap.MapParams(soc.memmap.MemUtil.strDevUser,get_param(dutBlks{i},'Name'),obj.DUTFixedBaseAddr,obj.defaultRange,dutBlks{i},regs)];
                else
                    obj.mmap.map=[obj.mmap.map;soc.memmap.MapParams(soc.memmap.MemUtil.strDevUser,get_param(dutBlks{i},'Name'),l_dec2hexAddr(obj.currRegAddrPtr),obj.defaultRange,dutBlks{i},regs)];
                    obj.currRegAddrPtr=obj.currRegAddrPtr+l_str2decRange(obj.defaultRange);
                end
            end


            unmappedDUTs=setdiff(obj.dut,dutBlks);
            for j=1:numel(unmappedDUTs)
                if obj.isFixedMemMap
                    obj.mmap.map=[obj.mmap.map;soc.memmap.MapParams(soc.memmap.MemUtil.strDevUser,get_param(unmappedDUTs{j},'Name'),obj.DUTFixedBaseAddr,obj.defaultRange,unmappedDUTs{j})];
                else
                    obj.mmap.map=[obj.mmap.map;soc.memmap.MapParams(soc.memmap.MemUtil.strDevUser,get_param(unmappedDUTs{j},'Name'),l_dec2hexAddr(obj.currRegAddrPtr),obj.defaultRange,unmappedDUTs{j})];
                    obj.currRegAddrPtr=obj.currRegAddrPtr+l_str2decRange(obj.defaultRange);
                end
            end
        end

        function genAutoImplicitIP(obj)

            if obj.FPGADesign.IncludeAXIInterconnectMonitor
                obj.mmap.map=[obj.mmap.map;soc.memmap.MapParams(soc.memmap.MemUtil.strDevImplicit,'APM',l_dec2hexAddr(obj.currRegAddrPtr),obj.defaultRange)];
                obj.currRegAddrPtr=obj.currRegAddrPtr+l_str2decRange(obj.defaultRange);
            end

            if~isempty(obj.implicitInfo)

                for i=1:numel(obj.implicitInfo)
                    impCompName=obj.implicitInfo{i};

                    if any(strcmp(impCompName,{obj.compAD9361IIC,obj.compAD9361AXI,obj.compHDMIAXI,obj.compHDMICtrl,obj.compAXIS2MMDMAC,obj.compAXIMM2SDMAC,obj.compRFDCAXI}))
                        [impCompAddr,impCompRange]=obj.getHardcodedAddr(impCompName);
                        obj.mmap.map=[obj.mmap.map;soc.memmap.MapParams(soc.memmap.MemUtil.strDevImplicit,impCompName,impCompAddr,impCompRange)];

                    elseif strcmp(impCompName,'VDMAFrameBuffer')
                        obj.mmap.map=[obj.mmap.map;soc.memmap.MapParams(soc.memmap.MemUtil.strDevImplicit,'VDMA Frame Buffer Write',l_dec2hexAddr(obj.currRegAddrPtr),obj.defaultRange)];
                        obj.currRegAddrPtr=obj.currRegAddrPtr+l_str2decRange(obj.defaultRange);
                        obj.mmap.map=[obj.mmap.map;soc.memmap.MapParams(soc.memmap.MemUtil.strDevImplicit,'VDMA Frame Buffer Read',l_dec2hexAddr(obj.currRegAddrPtr),obj.defaultRange)];
                        obj.currRegAddrPtr=obj.currRegAddrPtr+l_str2decRange(obj.defaultRange);

                    else
                        obj.mmap.map=[obj.mmap.map;soc.memmap.MapParams(soc.memmap.MemUtil.strDevImplicit,impCompName,l_dec2hexAddr(obj.currRegAddrPtr),obj.defaultRange)];
                        obj.currRegAddrPtr=obj.currRegAddrPtr+l_str2decRange(obj.defaultRange);
                    end
                end
            end
        end

        function genAutoCustomIP(obj,hsbMdlRef)

            if~isempty(which('soc.internal.isSoCBCustomIPBlk'))
                [cstmIPBlks,~]=soc.internal.findUniqueCustomIPBlks(hsbMdlRef);
                for i=1:numel(cstmIPBlks)
                    [~,internalCstmIPBlk]=soc.internal.isSoCBCustomIPBlk(cstmIPBlks{i});
                    intfInfo=soc.blkcb.customIPCb('getAXI4SlaveInfo',internalCstmIPBlk);
                    for ii=1:numel(intfInfo)
                        range={intfInfo(ii).Range,'K'};
                        obj.mmap.map=[obj.mmap.map;
                        soc.memmap.MapParams(soc.memmap.MemUtil.strDevCustom,intfInfo(ii).MemMapName,...
                        l_dec2hexAddr(obj.currRegAddrPtr),range,cstmIPBlks{i})];
                        obj.currRegAddrPtr=obj.currRegAddrPtr+l_str2decRange(range);
                    end
                end
            end
        end

        function mapSDRImplicitIP(obj)
            obj.implicitInfo=[obj.implicitInfo,obj.compAD9361IIC];
            obj.implicitInfo=[obj.implicitInfo,obj.compAD9361AXI];
        end

        function mapVisionImplicitIP(obj)
            obj.implicitInfo=[obj.implicitInfo,obj.compHDMIAXI];
            obj.implicitInfo=[obj.implicitInfo,obj.compHDMICtrl];
            obj.implicitInfo=[obj.implicitInfo,obj.compAXIS2MMDMAC];
            obj.implicitInfo=[obj.implicitInfo,obj.compAXIMM2SDMAC];
        end

        function mapRFDCImplicitIP(obj)
            obj.implicitInfo=[obj.implicitInfo,obj.compRFDCAXI];
        end

        function mapRegsWithDUT(obj,hsb_subsystem)

            if~isempty(hsb_subsystem)
                hsb_mdlref=get_param(hsb_subsystem,'ModelName');

                inp=find_system(hsb_mdlref,'SearchDepth',1,'BlockType','Inport');
                outp=find_system(hsb_mdlref,'SearchDepth',1,'BlockType','Outport');

                hsbSubsysTop=hsb_subsystem;
                mdlRefParent=get_param(hsb_subsystem,'Parent');
                if~strcmp(mdlRefParent,bdroot(hsb_subsystem))
                    hsbSubsysTop=mdlRefParent;
                end

                h_all_ports=get_param(hsbSubsysTop,'PortHandles');
                h_inp=h_all_ports.Inport;
                h_outp=h_all_ports.Outport;
                map_dut2reg=containers.Map;
                for ii=1:numel(h_inp)
                    this_h_inp=h_inp(ii);
                    h_line=get_param(this_h_inp,'Line');
                    hsb_mdlref_port=soc.util.getModelRefPort(hsbSubsysTop,hsb_subsystem,inp,ii,'in');
                    if isempty(hsb_mdlref_port)


                        continue;
                    end
                    if isequal(h_line,-1)
                        error(message('soc:msgs:portNotConnect','Input',num2str(ii),hsb_mdlref_port));
                    end
                    [src_blk,src_port,~,~]=soc.util.getHSBSrcBlk(h_line);

                    h_hsb_mdlref_port_lines=get_param(hsb_mdlref_port,'LineHandles');
                    h_line=h_hsb_mdlref_port_lines.Outport;
                    cntd_blks=soc.util.getDstBlk(h_line);
                    if~isempty(cntd_blks)&&~isempty(src_blk)
                        cntd_blk=cntd_blks{1};
                        if any(strcmpi(get_param(cntd_blk,'Name'),get_param(obj.dut,'Name')))&&...
                            any(strcmpi(soc.util.getRefBlk(src_blk),{'hsblib_beta2/Register Channel','socregisterchanneli2clib/Register Channel I2C','socmemlib/Register Channel'}))
                            if isKey(map_dut2reg,cntd_blk)
                                map_dut2reg(cntd_blk)=unique([map_dut2reg(cntd_blk),src_blk]);
                            else
                                map_dut2reg(cntd_blk)={src_blk};
                            end
                        elseif any(strcmpi(soc.util.getRefBlk(src_blk),{'socmemlib/Memory Channel',...
                            'socmemlib/AXI4-Stream to Software',...
                            'socmemlib/Software to AXI4-Stream',...
                            'socmemlib/AXI4 Random Access Memory',...
                            'socmemlib/AXI4 Video Frame Buffer'}))
                            obj.implicitInfo=[obj.implicitInfo,soc.memmap.blk2fpga(obj.FPGAVendor,src_blk,src_port)];
                        end
                    end
                end

                for jj=1:numel(h_outp)
                    this_h_outp=h_outp(jj);
                    h_line=get_param(this_h_outp,'Line');
                    hsb_mdlref_port=soc.util.getModelRefPort(hsbSubsysTop,hsb_subsystem,outp,jj,'out');
                    if isempty(hsb_mdlref_port)


                        continue;
                    end
                    if isequal(h_line,-1)
                        error(message('soc:msgs:portNotConnect','Output',num2str(jj),hsb_mdlref_port));
                    end
                    [dst_blks,dst_ports,~,~]=soc.util.getHSBDstBlk(h_line);
                    if~isempty(dst_blks)
                        dst_blk=dst_blks{1};
                        dst_port=dst_ports(1);
                    else
                        dst_blk='';
                        dst_port='';
                    end


                    h_hsb_mdlref_port_lines=get_param(hsb_mdlref_port,'LineHandles');
                    h_line=h_hsb_mdlref_port_lines.Inport;
                    cntd_blk=soc.util.getSrcBlk(h_line);
                    if~isempty(cntd_blk)&&~isempty(dst_blk)
                        if any(strcmpi(get_param(cntd_blk,'Name'),get_param(obj.dut,'Name')))&&...
                            any(strcmpi(soc.util.getRefBlk(dst_blk),{'hsblib_beta2/Register Channel','socregisterchanneli2clib/Register Channel I2C','socmemlib/Register Channel'}))
                            if isKey(map_dut2reg,cntd_blk)
                                map_dut2reg(cntd_blk)=unique([map_dut2reg(cntd_blk),dst_blk]);
                            else
                                map_dut2reg(cntd_blk)={dst_blk};
                            end
                        elseif any(strcmpi(soc.util.getRefBlk(dst_blk),{'socmemlib/Memory Channel',...
                            'socmemlib/AXI4-Stream to Software',...
                            'socmemlib/Software to AXI4-Stream',...
                            'socmemlib/AXI4 Random Access Memory',...
                            'socmemlib/AXI4 Video Frame Buffer'}))
                            obj.implicitInfo=[obj.implicitInfo,soc.memmap.blk2fpga(obj.FPGAVendor,dst_blk,dst_port)];
                        end
                    end
                end
                obj.dutMap=map_dut2reg;
            end
            if~isempty(obj.implicitInfo)
                obj.implicitInfo=unique(obj.implicitInfo);
            end
        end

        function[addr,range]=getHardcodedAddr(obj,comp)

            addr='0x00000000';
            range=obj.defaultRange;

            if strcmp(obj.FPGAVendor,'Xilinx')
                switch comp
                case obj.compAD9361IIC
                    addr='0x41620000';
                case obj.compAD9361AXI
                    addr='0x43C00000';
                case obj.compHDMIAXI
                    addr='0x41630000';
                case obj.compHDMICtrl
                    addr='0x43C00000';
                case obj.compAXIS2MMDMAC
                    addr='0x44B00000';
                case obj.compAXIMM2SDMAC
                    addr='0x44B10000';
                case obj.compRFDCAXI
                    addr='0xA3C00000';
                    range={'256','K'};
                end
            elseif strcmp(obj.FPGAVendor,'Intel')

            end
        end

        function offset=genRegOffsets(obj,regLenStr)
            offset={};
            currAddrPtr=double(l_hex2decAddr(obj.defaultRegOffset))/obj.controllerInfo.regSize;
            regLen=cellfun(@eval,regLenStr,'UniformOutput',false);
            for i=1:numel(regLen)
                offset{i}=l_calcCurrAddr(currAddrPtr,regLen{i});
                currAddrPtr=l_calcEndAddr(offset{i},regLen{i});
            end
            offset=strcat('0x0',cellfun(@(x)dec2hex(obj.controllerInfo.regSize*x),offset,'UniformOutput',false));
        end

        function writeToModelWorkspace(obj)
            savedMap=soc.memmap.getMemoryMap(obj.mdlH);
            [~,equalSaved]=soc.memmap.compareMaps(savedMap,obj.mmap);

            if equalSaved
                mustSave=false;
            else
                mustSave=true;


                autoMap=soc.memmap.genAutoMap(obj.mdlH);
                [~,equalAuto]=soc.memmap.compareMaps(autoMap,obj.mmap);

                if equalAuto
                    if~obj.mmap.isAutoMap
                        obj.mmap.isAutoMap=true;
                    end

                else
                    obj.mmap.isAutoMap=false;
                end
            end
            if mustSave
                soc.memmap.setMemoryMap(obj.mdlH,obj.mmap);
            end
        end

        function tf=needsReconciliation(obj)
            autoMap=soc.memmap.genAutoMap(obj.mdlH);
            areCompatible=soc.memmap.compareMaps(autoMap,obj.mmap);
            tf=~areCompatible;
        end


    end
end


function currAddrUpdated=l_calcCurrAddr(currAddr,length)
    if length==1
        currAddrUpdated=currAddr;
    else
        currAddrUpdated=ceil(currAddr/l_getVecBlockSize(length))*l_getVecBlockSize(length);
    end
end

function endAddr=l_calcEndAddr(startAddr,length)
    if length==1
        endAddr=startAddr+1;
    else
        endAddr=startAddr+l_getVecBlockSize(length)+1;
    end
end

function addrBlockSize=l_getVecBlockSize(length)
    addrBlockSize=2^(ceil(log2(length)));
end

function highestAddress=l_trackHighestAddress(highestAddress,currEntry)
    currLastAddress=currEntry.getLastAddress();
    switch currEntry.type
    case{soc.memmap.MemUtil.strDevPSMemory,soc.memmap.MemUtil.strDevPLMemory}
        if currLastAddress>highestAddress(1)
            highestAddress(1)=currLastAddress;
        end
    otherwise
        if currLastAddress>highestAddress(2)
            highestAddress(2)=currLastAddress;
        end
    end
end
function alignedAddress=l_calcNextAlignedAddress(lastAddr,type)
    switch type
    case{soc.memmap.MemUtil.strDevPSMemory,soc.memmap.MemUtil.strDevPLMemory}
        la=lastAddr(1);

        alignVal=1*1024;
    otherwise
        la=lastAddr(2);
        alignVal=64*1024;
    end
    alignedAddress=ceil(la/alignVal)*alignVal;
end
function l_checkMemBlockOnTop(mdl)




    memBlocks=[find_system(mdl,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','socmemlib/Memory Channel');
    find_system(mdl,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','socmemlib/AXI4-Stream to Software');
    find_system(mdl,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','socmemlib/Software to AXI4-Stream');
    find_system(mdl,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','socmemlib/AXI4 Random Access Memory');
    find_system(mdl,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','socmemlib/AXI4 Video Frame Buffer');
    find_system(mdl,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','socmemlib/Memory Controller');
    find_system(mdl,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','socmemlib_internal/Memory Controller')];

    if any(~strcmpi(get_param(memBlocks,'parent'),mdl))
        error(message('soc:msgs:MemBlocksNotOnTop'));
    end
end
function mem_type=l_getMemChBlkType(memChBlk)
    if strcmpi(soc.util.getRefBlk(memChBlk),'socmemlib/Memory Channel')
        blkPortHandles=get_param(memChBlk,'porthandles');
        wrBurstReq='/wrBurstReq';
        burstReqPortNum=get_param(strcat(memChBlk,wrBurstReq),'port');
        handleLine=get_param(blkPortHandles.Outport(str2double(burstReqPortNum)),'Line');
        memCtrlBlk=soc.util.getDstBlk(handleLine);
        if any(strcmpi(soc.util.getRefBlk(memCtrlBlk{1}),{'socmemlib/Memory Controller','socmemlib_internal/Memory Controller'}))
            memSel=get_param(memCtrlBlk{1},'MemorySelection');
        else
            error("No Memory Controller attached to Memory Channel block: %s",memChBlk);
        end
    else
        memSel=get_param(memChBlk,'MemorySelection');
    end
    switch memSel
    case 'PL memory'
        mem_type='memPL';
    case 'PS memory'
        mem_type='memPS';
    otherwise
        error('Invalid Memory Selection: %s in Memory Controller block: %s ',memSel,memCtrlBlk);
    end
end

function hexAddr=l_dec2hexAddr(decAddr)
    hexAddr=['0x',dec2hex(decAddr,8)];
end

function decAddr=l_hex2decAddr(hexAddr)
    decAddr=uint64(hex2dec(hexAddr));
end

function decRange=l_str2decRange(strRange)
    switch strRange{2}
    case ''
        mult=uint64(1);
    case 'K'
        mult=uint64(1024);
    case 'M'
        mult=uint64(1024*1024);
    case 'G'
        mult=uint64(1024*1024*1024);
    case 'T'
        mult=uint64(1024*1024*1024*1024);
    otherwise
        mult=uint64(1);
    end
    decRange=uint64(str2double(strRange{1})*mult);
end

function strRange=l_dec2strRange(decRange)
    decRange=double(decRange);
    if decRange<1024
        strRange={num2str(decRange),''};
    elseif decRange<(1024*1024)
        strRange={num2str(decRange/(1024)),'K'};
    elseif decRange<(1024*1024*1024)
        strRange={num2str(decRange/(1024*1024)),'M'};
    elseif decRange<(1024*1024*1024*1024)
        strRange={num2str(decRange/(1024*1024*1024)),'G'};
    else
        strRange={num2str(decRange/(1024*1024*1024*1024)),'T'};
    end
end

function strRangeAligned=l_get4KAlignedRange(strRange)
    strRangeAligned={num2str((ceil(double(l_str2decRange(strRange))/4096)*4096)/1024),'K'};
end



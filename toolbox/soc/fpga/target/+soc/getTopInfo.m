function topInfo=getTopInfo(sys,memMap,dut,hasRd)




    [fpgaModelBlock,fpgaModel]=soc.util.getHSBSubsystem(sys);
    vendor=soc.internal.getVendor(sys);
    topComps={};
    intfInfo=containers.Map;
    hasReferenceDesign=false;
    if nargin==4
        hasReferenceDesign=hasRd;
    end
    if~isempty(fpgaModelBlock)

        inp=find_system(fpgaModel,'SearchDepth',1,'BlockType','Inport');
        outp=find_system(fpgaModel,'SearchDepth',1,'BlockType','Outport');


        hsbSubsysTop=fpgaModelBlock;
        mdlRefParent=get_param(fpgaModelBlock,'Parent');
        if~strcmp(mdlRefParent,sys)
            hsbSubsysTop=mdlRefParent;
        end


        handleAllTopPorts=get_param(hsbSubsysTop,'PortHandles');
        handleTopInPorts=handleAllTopPorts.Inport;
        handleTopOutPorts=handleAllTopPorts.Outport;
        for ii=1:numel(handleTopInPorts)
            thisHandleTopInPort=handleTopInPorts(ii);
            hsbMdlRefPort=soc.util.getModelRefPort(hsbSubsysTop,fpgaModelBlock,inp,ii,'in');
            if isempty(hsbMdlRefPort)


                continue;
            end
            handleLine=get_param(thisHandleTopInPort,'Line');
            if isequal(handleLine,-1)
                error(message('soc:msgs:portNotConnect','Input',num2str(ii),hsbMdlRefPort));
            end
            [srcBlk,srcPort,~,handleSrcPort]=soc.util.getHSBSrcBlk(handleLine);


            if isempty(srcBlk)&&~hasReferenceDesign
                error(message('soc:msgs:portNotConnectSoCBlk','Input',num2str(ii),hsbMdlRefPort));
            end

            if~isempty(srcBlk)
                if startsWith(libinfo(srcBlk,'searchdepth',0).ReferenceBlock,'hwlogicconnlib')
                    error(message('soc:msgs:IlleagalUseOfHWLogicConnBlks',srcBlk));
                end
                thisComp=soc.util.blk2fpgacomp(memMap,vendor,srcBlk,srcPort);
                if~isempty(thisComp)
                    if isa(thisComp,'soc.xilcomp.AXIM')||isa(thisComp,'soc.intelcomp.AXIM')
                        if~any(cellfun(@(x)(strcmpi(x.BlkName,thisComp.BlkName)&&strcmpi(x.Configuration.type,thisComp.Configuration.type)),topComps))
                            topComps{end+1}=thisComp;
                        end
                    else
                        if~any(cellfun(@(x)(strcmpi(x.BlkName,thisComp.BlkName)&&strcmpi(class(x),class(thisComp))),topComps))
                            topComps{end+1}=thisComp;
                        end
                    end
                end


                srcIO=soc.util.hsbport2fpgaio(vendor,srcBlk,srcPort);


                if strcmp(libinfo(srcBlk,'searchdepth',0).ReferenceBlock,'xilinxsocvisionlib/HDMI Rx')
                    fpgaPort=get_param(hsbMdlRefPort,'PortConnectivity');
                    fpgaBlkPath=getfullname(fpgaPort.DstBlock);
                    if isempty(libinfo(fpgaBlkPath,'searchdepth',0))||...
                        ~strcmp(libinfo(fpgaBlkPath,'searchdepth',0).ReferenceBlock,'hwlogicconnlib/Video Stream Connector')
                        error(message('soc:msgs:IlleagalHDMICntn',srcBlk));
                    end
                end


                if isa(thisComp,'soc.xilcomp.VDMAFrameBuffer')||...
                    isa(thisComp,'soc.xilcomp.VDMAWrite')||...
                    isa(thisComp,'soc.xilcomp.VDMARead')

                    fpgaPort=get_param(hsbMdlRefPort,'Porthandles');
                    fpgaBlkPath=soc.util.getDstBlk(get_param(fpgaPort.Outport,'line'));
                    if strcmp(srcPort,'wrCtrlOut')


                        if isempty(libinfo(fpgaBlkPath{1},'searchdepth',0))||...
                            ~strcmp(libinfo(fpgaBlkPath{1},'searchdepth',0).ReferenceBlock,'hwlogicconnlib/SoC Bus Selector')
                            error(message('soc:msgs:VideoStreamRdy',srcPort,srcBlk,'SoC Bus Selector'));
                        end
                    elseif strcmp(srcPort,'rdCtrlOut')


                        fpgaDUTName=getDstDUTName(thisComp,hsbSubsysTop,fpgaModelBlock,inp);
                        if~strcmp(fpgaDUTName,fpgaBlkPath{1})
                            error(message('soc:msgs:VideoStreamPxlBus',srcPort,srcBlk,fpgaDUTName));
                        end
                    end
                end


                if isa(thisComp,'soc.xilcomp.AXIM')||isa(thisComp,'soc.intelcomp.AXIM')

                    fpgaPort=get_param(hsbMdlRefPort,'Porthandles');
                    fpgaBlkPath=soc.util.getDstBlk(get_param(fpgaPort.Outport,'line'));
                    if any(strcmp(srcPort,{'rdCtrlOut','wrCtrlOut'}))


                        if strcmp(srcPort,'rdCtrlOut')
                            fpgaDUTName=getDstDUTName(thisComp,hsbSubsysTop,fpgaModelBlock,inp);
                        elseif strcmp(srcPort,'wrCtrlOut')
                            fpgaDUTName=getSrcDUTName(thisComp,hsbSubsysTop,fpgaModelBlock,outp);
                        end
                        if~strcmp(fpgaDUTName,fpgaBlkPath{1})
                            error(message('soc:msgs:AXI4CtrlInterface',srcPort,srcBlk,fpgaDUTName));
                        end
                    end
                end
                if~isempty(srcIO)
                    if isa(thisComp,'soc.xilcomp.AXIM')||isa(thisComp,'soc.intelcomp.AXIM')
                        intfInfo(hsbMdlRefPort)=struct('interface',srcIO,'interfacePort',srcPort,'dataWidth',thisComp.Configuration.mm_dw,'memType',thisComp.Configuration.mem_type);
                    else
                        intfInfo(hsbMdlRefPort)=struct('interface',srcIO,'interfacePort',srcPort);
                    end
                elseif(any(strcmpi(soc.util.getRefBlk(srcBlk),{'hsblib_beta2/Register Channel','socregisterchanneli2clib/Register Channel I2C','socmemlib/Register Channel'})))
                    if strcmpi(vendor,'xilinx')
                        intfInfo(hsbMdlRefPort)=struct('interface','axi4_lite');
                    else
                        intfInfo(hsbMdlRefPort)=struct('interface','axi4');
                    end
                    regTableName=eval(get_param(srcBlk,'regtablenames'));

                    regName=regTableName{get_param(handleSrcPort,'PortNumber')};

                    blkName=getRegBlkName(hsbMdlRefPort,'input');
                    if~any(strcmp(blkName,dut))
                        error(message('soc:msgs:RegPortNotConnctdToDUT',hsbMdlRefPort,strjoin(dut,', ')));
                    end

                    regOffset=soc.memmap.getRegOffset(memMap,blkName,regName);

                    regOffset=['x"',regOffset(3:end),'"'];
                    thisIntfInfo=intfInfo(hsbMdlRefPort);
                    thisIntfInfo.regOffset=regOffset;
                    intfInfo(hsbMdlRefPort)=thisIntfInfo;
                end
            end
        end

        for jj=1:numel(handleTopOutPorts)
            thisHandleTopOutPort=handleTopOutPorts(jj);
            hsbMdlRefPort=soc.util.getModelRefPort(hsbSubsysTop,fpgaModelBlock,outp,jj,'out');
            if isempty(hsbMdlRefPort)


                continue;
            end
            handleLine=get_param(thisHandleTopOutPort,'Line');
            if isequal(handleLine,-1)
                error(message('soc:msgs:portNotConnect','Output',num2str(jj),hsbMdlRefPort));
            end
            [dstBlks,dstPorts,~,handleDstPorts]=soc.util.getHSBDstBlk(handleLine);

            if(numel(dstBlks)>1)
                error(message('soc:msgs:portConnectToMultipleSoCBlks','Output',num2str(jj),hsbMdlRefPort))
            elseif isempty(dstBlks)&&~hasReferenceDesign
                error(message('soc:msgs:portNotConnectSoCBlk','Output',num2str(jj),hsbMdlRefPort));
            end


            if~isempty(dstBlks)
                if startsWith(libinfo(dstBlks,'searchdepth',0).ReferenceBlock,'hwlogicconnlib')
                    error(message('soc:msgs:IlleagalUseOfHWLogicConnBlks',dstBlks{1}));
                end
                dstBlk=dstBlks{1};
                dstPort=dstPorts{1};
                handleDstPort=handleDstPorts(1);
                thisComp=soc.util.blk2fpgacomp(memMap,vendor,dstBlk,dstPort);
                if~isempty(thisComp)
                    if isa(thisComp,'soc.xilcomp.AXIM')||isa(thisComp,'soc.intelcomp.AXIM')
                        if~any(cellfun(@(x)(strcmpi(x.BlkName,thisComp.BlkName)&&strcmpi(x.Configuration.type,thisComp.Configuration.type)),topComps))
                            topComps{end+1}=thisComp;
                        end
                    else
                        if~any(cellfun(@(x)(strcmpi(x.BlkName,thisComp.BlkName)&&strcmpi(class(x),class(thisComp))),topComps))
                            topComps{end+1}=thisComp;
                        end
                    end
                end


                dstIO=soc.util.hsbport2fpgaio(vendor,dstBlk,dstPort);


                if strcmp(libinfo(dstBlk,'searchdepth',0).ReferenceBlock,'xilinxsocvisionlib/HDMI Tx')
                    fpgaPort=get_param(hsbMdlRefPort,'PortConnectivity');
                    fpgaBlkPath=getfullname(fpgaPort.SrcBlock);
                    if isempty(libinfo(fpgaBlkPath,'searchdepth',0))||...
                        ~strcmp(libinfo(fpgaBlkPath,'searchdepth',0).ReferenceBlock,'hwlogicconnlib/Video Stream Connector')
                        error(message('soc:msgs:IlleagalHDMICntn',dstBlk));
                    end
                end


                if isa(thisComp,'soc.xilcomp.VDMAFrameBuffer')||...
                    isa(thisComp,'soc.xilcomp.VDMAWrite')||...
                    isa(thisComp,'soc.xilcomp.VDMARead')

                    fpgaPort=get_param(hsbMdlRefPort,'Porthandles');
                    fpgaBlkPath=soc.util.getSrcBlk(get_param(fpgaPort.Inport,'line'));
                    if strcmp(dstPort,'rdCtrlIn')


                        if isempty(libinfo(fpgaBlkPath,'searchdepth',0))||...
                            ~strcmp(libinfo(fpgaBlkPath,'searchdepth',0).ReferenceBlock,'hwlogicconnlib/SoC Bus Creator')
                            error(message('soc:msgs:VideoStreamRdy',dstPort,dstBlk,'SoC Bus Creator '));
                        end
                    elseif strcmp(dstPort,'wrCtrlIn')


                        fpgaDUTName=getSrcDUTName(thisComp,hsbSubsysTop,fpgaModelBlock,outp);
                        if~strcmp(fpgaDUTName,fpgaBlkPath)
                            error(message('soc:msgs:VideoStreamPxlBus',dstPort,dstBlk,fpgaDUTName));
                        end
                    end
                end


                if isa(thisComp,'soc.xilcomp.AXIM')||isa(thisComp,'soc.intelcomp.AXIM')

                    fpgaPort=get_param(hsbMdlRefPort,'Porthandles');
                    fpgaBlkPath=soc.util.getSrcBlk(get_param(fpgaPort.Inport,'line'));
                    if any(strcmp(dstPort,{'rdCtrlIn','wrCtrlIn'}))


                        if strcmp(dstPort,'wrCtrlIn')
                            fpgaDUTName=getSrcDUTName(thisComp,hsbSubsysTop,fpgaModelBlock,outp);
                        elseif strcmp(dstPort,'rdCtrlIn')
                            fpgaDUTName=getDstDUTName(thisComp,hsbSubsysTop,fpgaModelBlock,inp);
                        end
                        if~strcmp(fpgaDUTName,fpgaBlkPath)
                            error(message('soc:msgs:AXI4CtrlInterface',dstPort,dstBlk,fpgaDUTName));
                        end
                    end
                end
                if~isempty(dstIO)
                    if isa(thisComp,'soc.xilcomp.AXIM')||isa(thisComp,'soc.intelcomp.AXIM')
                        intfInfo(hsbMdlRefPort)=struct('interface',dstIO,'interfacePort',dstPort,'dataWidth',thisComp.Configuration.mm_dw,'memType',thisComp.Configuration.mem_type);
                    else
                        intfInfo(hsbMdlRefPort)=struct('interface',dstIO,'interfacePort',dstPort);
                    end
                elseif(any(strcmpi(soc.util.getRefBlk(dstBlk),{'hsblib_beta2/Register Channel','socregisterchanneli2clib/Register Channel I2C','socmemlib/Register Channel'})))
                    if strcmpi(vendor,'xilinx')
                        intfInfo(hsbMdlRefPort)=struct('interface','axi4_lite');
                    else
                        intfInfo(hsbMdlRefPort)=struct('interface','axi4');
                    end
                    regTableName=eval(get_param(dstBlk,'regtablenames'));

                    regName=regTableName{get_param(handleDstPort,'PortNumber')};

                    blkName=getRegBlkName(hsbMdlRefPort,'output');
                    if~any(strcmp(blkName,dut))
                        error(message('soc:msgs:RegPortNotConnctdToDUT',hsbMdlRefPort,strjoin(dut,', ')));
                    end

                    regOffset=soc.memmap.getRegOffset(memMap,blkName,regName);

                    regOffset=['x"',regOffset(3:end),'"'];
                    thisIntfInfo=intfInfo(hsbMdlRefPort);
                    thisIntfInfo.regOffset=regOffset;
                    intfInfo(hsbMdlRefPort)=thisIntfInfo;
                elseif strcmpi(soc.util.getRefBlk(dstBlk),'socmemlib/Interrupt Channel')
                    intrChPortNum=str2double(get_param([dstBlk,'/',dstPort],'port'));
                    blkP=soc.blkcb.cbutils('GetDialogParams',dstBlk);
                    triggerType=blkP.IntTableTriggers{intrChPortNum};
                    intfInfo(hsbMdlRefPort)=struct('interface','interrupt','intrChPortNum',intrChPortNum,'triggerType',triggerType);
                end
            end
        end
    end



    dummyBlks=find_system(sys,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','socmemlib/Memory Traffic Generator');

    for kk=1:numel(dummyBlks)
        thisComp=soc.util.blk2fpgacomp(memMap,vendor,dummyBlks{kk},kk-1);
        topComps{end+1}=thisComp;%#ok<AGROW>
    end


    topInfo.comps=topComps;
    topInfo.sys=sys;
    topInfo.intfInfo=intfInfo;

end


function blkName=getRegBlkName(portName,direction)
    handles=get_param(portName,'LineHandles');
    blkName=[];
    switch direction
    case 'input'
        lineH=handles.Outport;
        [dstBlks,~,~,~]=soc.util.getDstBlk(lineH);
        if~isempty(dstBlks)
            blkName=dstBlks{1};
        else
            blkName='';
        end
    case 'output'
        lineH=handles.Inport;
        [blkName,~,~,~]=soc.util.getSrcBlk(lineH);
    end
    blkName=get_param(blkName,'name');
end

function fpgaDUTName=getDstDUTName(thisComp,hsbSubsysTop,fpgaModelBlock,inp)


    memChPortHdl=get_param(thisComp.BlkName,'Porthandles');
    rdDataPortNum=get_param([thisComp.BlkName,'/','rdData'],'Port');
    [dstTopBlk,dstTopPort]=soc.util.getDstBlk(get_param(memChPortHdl.Outport(str2double(rdDataPortNum)),'line'));
    if ischar(dstTopPort{1})
        dstTopPortNum=get_param([dstTopBlk{1},'/',dstTopPort{1}],'port');
    else
        dstTopPortNum=num2str(dstTopPort{1});
    end
    rdDataFPGAPort=soc.util.getModelRefPort(hsbSubsysTop,fpgaModelBlock,inp,str2double(dstTopPortNum),'in');
    fpgaDUT=get_param(rdDataFPGAPort,'PortConnectivity');
    fpgaDUTName=getfullname(fpgaDUT.DstBlock);
end

function fpgaDUTName=getSrcDUTName(thisComp,hsbSubsysTop,fpgaModelBlock,outp)


    memChPortHdl=get_param(thisComp.BlkName,'Porthandles');
    wrDataPortNum=get_param([thisComp.BlkName,'/','wrData'],'Port');
    [srcTopBlk,srcTopPort]=soc.util.getSrcBlk(get_param(memChPortHdl.Inport(str2double(wrDataPortNum)),'line'));
    if ischar(srcTopPort)
        srcTopPortNum=get_param([srcTopBlk,'/',srcTopPort],'port');
    else
        srcTopPortNum=num2str(srcTopPort);
    end
    wrDataFPGAPort=soc.util.getModelRefPort(hsbSubsysTop,fpgaModelBlock,outp,str2double(srcTopPortNum),'out');
    fpgaDUT=get_param(wrDataFPGAPort,'PortConnectivity');
    fpgaDUTName=getfullname(fpgaDUT.SrcBlock);
end

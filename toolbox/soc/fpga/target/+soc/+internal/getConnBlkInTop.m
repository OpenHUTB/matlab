function[blk,port]=getConnBlkInTop(sys,fpgaPortName)
    blk='';
    port='';
    [fpgaModelBlock,~]=soc.util.getHSBSubsystem(sys);

    if~isempty(fpgaModelBlock)

        hsbSubsysTop=fpgaModelBlock;
        mdlRefParent=get_param(fpgaModelBlock,'Parent');
        if~strcmp(mdlRefParent,sys)
            hsbSubsysTop=mdlRefParent;
            blkPortH=get_param(hsbSubsysTop,'porthandles');
            portName=get_param(fpgaPortName,'name');
            fpgaPortNum=str2double(get_param(fpgaPortName,'port'));
            portType=get_param(fpgaPortName,'blocktype');
            if strcmpi(get_param(hsbSubsysTop,'Variant'),'on')
                hsbSubSysPorts=find_system(hsbSubsysTop,'Searchdepth',1,'lookundermasks','on','blocktype',portType);
                hsbSubSysPortNames=strtrim(get_param(hsbSubSysPorts,'name'));
                variantPort=hsbSubSysPorts(strcmp(hsbSubSysPortNames,portName));
                portNum=str2double(get_param(variantPort,'port'));
            else
                fpgaMdlBlkPortH=get_param(fpgaModelBlock,'porthandles');
                if strcmpi(portType,'Inport')
                    [blk,port]=soc.util.getSrcBlk(get_param(fpgaMdlBlkPortH.Inport(fpgaPortNum),'line'));
                elseif strcmpi(portType,'Outport')
                    [blk,port]=soc.util.getDstBlk(get_param(fpgaMdlBlkPortH.Outport(fpgaPortNum),'line'));
                end
                if~(strcmpi(get_param(blk,'blocktype'),'Inport')||strcmpi(get_param(blk,'blocktype'),'Outport'))
                    return;
                end
                portNum=str2double(get_param(blk,'port'));
                if iscell(portNum)
                    portNum=portNum{1};
                end
            end

            if strcmpi(portType,'Inport')
                [blk,port]=soc.util.getHSBSrcBlk(get_param(blkPortH.Inport(portNum),'line'));
            elseif strcmpi(portType,'Outport')
                [blk,port]=soc.util.getHSBDstBlk(get_param(blkPortH.Outport(portNum),'line'));
            end
        else
            blkPortH=get_param(hsbSubsysTop,'porthandles');
            portNum=str2double(get_param(fpgaPortName,'port'));
            portType=get_param(fpgaPortName,'blocktype');
            if strcmpi(portType,'Inport')
                [blk,port]=soc.util.getHSBSrcBlk(get_param(blkPortH.Inport(portNum),'line'));
            elseif strcmpi(portType,'Outport')
                [blk,port]=soc.util.getHSBDstBlk(get_param(blkPortH.Outport(portNum),'line'));
            end
        end
    end
end
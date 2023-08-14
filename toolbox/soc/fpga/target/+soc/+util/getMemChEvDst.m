function[memChEvntDstBlk,portName]=getMemChEvDst(blk,port)
    portName='';
    memChEvntDstBlk='';
    portHndl=get_param(blk,'PortHandles');
    if strcmpi(get_param(blk,'blocktype'),'subsystem')
        portNum=get_param([blk,'/',port],'port');
        handleLine=get_param(portHndl.Outport(str2double(portNum)),'Line');
    else
        handleLine=get_param(portHndl.Outport,'Line');
    end
    if handleLine~=-1
        h_blks=get_param(handleLine,'DstBlockHandle');
        memChEvntDstBlk=getfullname(h_blks);
        blkLibInfo=libinfo(memChEvntDstBlk,'searchdepth',0);
        if strcmpi(get_param(memChEvntDstBlk,'blocktype'),'subsystem')
            h_ports=get_param(handleLine,'DstPortHandle');
            dst_port_num=get_param(h_ports,'PortNumber');
            ip=find_system(h_blks,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Inport');
            portName=get_param(ip(dst_port_num),'Name');
            if isempty(blkLibInfo)
                [memChEvntDstBlk,portName]=soc.util.getMemChEvDst([memChEvntDstBlk,'/',portName]);
            end
        end
    end
end
function[blks,ports,h_blks,h_ports]=getDstBlk(this_line)





    ports={};
    h_blks=get_param(this_line,'DstBlockHandle');
    h_ports=get_param(this_line,'DstPortHandle');



    h_blks(h_blks==-1)='';
    h_ports(h_ports==-1)='';

    if~isempty(h_blks)
        blks_type=get_param(h_blks,'BlockType');


        valid_blk_idx=~(...
        strcmpi(blks_type,'Display')|...
        strcmpi(blks_type,'Scope')|...
        strcmpi(blks_type,'ToFile')|...
        strcmpi(blks_type,'ToWorkspace')|...
        strcmpi(blks_type,'Terminator'));

        h_blks=h_blks(valid_blk_idx);
        h_ports=h_ports(valid_blk_idx);
    end

    if isempty(h_blks)
        blks='';
        ports='';
    elseif numel(h_blks)>1
        blks=getfullname(h_blks);
    else
        blks{1}=getfullname(h_blks);
    end

    if~isempty(blks)
        gotoBlkIndx=find(strcmpi(get_param(blks,'BlockType'),'goto'));
    else
        gotoBlkIndx=[];
    end
    blksCopy=blks;
    blks(gotoBlkIndx)=[];
    h_blks(gotoBlkIndx)=[];
    h_ports(gotoBlkIndx)=[];


    for i=gotoBlkIndx'
        blk=blksCopy{i};
        goto_tag=get_param(blk,'GotoTag');
        sys=get_param(blk,'Parent');


        from_blk=find_system(sys,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks','on','GotoTag',goto_tag,'BlockType','From');
        if isempty(from_blk)
            error(message('soc:msgs:NoFromBlockFound',blk));
        end
        from_blk_ph=get_param(from_blk{1},'PortHandles');
        from_blk_lh=get_param(from_blk_ph.Outport,'Line');
        destBlksH=get_param(from_blk_lh,'DstBlockHandle');
        destPortsH=get_param(from_blk_lh,'DstPortHandle');
        destBlks=getfullname(destBlksH);
        if~iscell(destBlks),destBlks={destBlks};end

        blks=[blks;destBlks];%#ok<*AGROW>
        h_blks=[h_blks;destBlksH];
        h_ports=[h_ports;destPortsH];
    end

    for i=1:numel(h_blks)
        dst_port_num=get_param(h_ports(i),'PortNumber');
        ip=find_system(h_blks(i),'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Inport');
        ip=[ip;find_system(h_blks(i),'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','EnablePort')];
        if isempty(ip)
            ports{end+1}=soc.util.getSystemBlkPortName(h_blks(i),'input',dst_port_num);
        else
            ports{end+1}=get_param(ip(dst_port_num),'Name');
        end
    end
end

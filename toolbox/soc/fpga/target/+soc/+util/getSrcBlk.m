function[blk,port,h_blk,h_port]=getSrcBlk(this_line)





    h_blk=get_param(this_line,'SrcBlockHandle');
    h_port=get_param(this_line,'SrcPortHandle');
    if(h_blk==-1)
        blk='';
        port='';
        h_blk='';
        h_port='';
    else
        blk=getfullname(h_blk);
        if strcmpi(get_param(blk,'BlockType'),'from')
            goto_tag=get_param(blk,'GotoTag');
            sys=get_param(blk,'Parent');


            goto_blk=find_system(sys,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks','on','GotoTag',goto_tag,'BlockType','Goto');
            if isempty(goto_blk)
                error(message('soc:msgs:NoGotoBlockFound',blk));
            end
            goto_blk_ph=get_param(goto_blk{1},'PortHandles');
            goto_blk_lh=get_param(goto_blk_ph.Inport,'Line');
            h_blk=get_param(goto_blk_lh,'SrcBlockHandle');
            h_port=get_param(goto_blk_lh,'SrcPortHandle');
            blk=getfullname(h_blk);
        end

        src_port_num=get_param(h_port,'PortNumber');
        op=find_system(h_blk,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Outport');
        if isempty(op)
            port=soc.util.getSystemBlkPortName(h_blk,'output',src_port_num);
        else
            port=get_param(op(src_port_num),'Name');
        end
    end

end






function[blk,port,h_blk,h_port]=getHSBSrcBlk(h_line)
    blk='';
    port='';
    h_blk='';
    h_port='';
    [src_blk,src_port,h_src_blk,h_src_port]=soc.util.getSrcBlk(h_line);
    if~isempty(src_blk)
        if startsWith(soc.util.getRefBlk(src_blk),{'hsblib_beta2','hsbhdllib','hwlogiciolib','socregisterchanneli2clib','xilinxsocad9361lib','xilinxsocvisionlib','hwlogicconnlib','socmemlib','xilinxrfsoclib','soclib_beta'})
            blk=src_blk;
            port=src_port;
            h_blk=h_src_blk;
            h_port=h_src_port;
        else
            if strcmpi(get_param(src_blk,'BlockType'),'subsystem')
                if strcmpi(get_param(src_blk,'Variant'),'on')
                    active_blk=get_param(src_blk,'ActiveVariantBlock');
                    active_blk_fullname=getfullname(active_blk);
                    if startsWith(soc.util.getRefBlk(active_blk_fullname),{'hsblib_beta2','hsbhdllib','hwlogiciolib','hwlogicconnlib','socmemlib','xilinxrfsoclib','soclib_beta'})
                        src_port_num=get_param(h_src_port,'PortNumber');
                        blk=active_blk_fullname;
                        port_cell=find_system(active_blk,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Outport');
                        port=get_param(port_cell{src_port_num},'Name');
                        h_blk=get_param(active_blk,'Handle');
                        h_port_all=get_param(active_blk,'PortHandles');
                        h_port=h_port_all.Outport(src_port_num);
                    end
                else


                    connected_port=find_system(src_blk,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','Outport','Port',num2str(get_param(h_src_port,'PortNumber')));
                    if~isempty(connected_port)
                        phs=get_param(connected_port{1},'PortHandles');
                        lh=get_param(phs.Inport,'Line');
                        [blk,port,h_blk,h_port]=soc.util.getHSBSrcBlk(lh);
                    end
                end
            else
                phs=get_param(src_blk,'PortHandles');
                if numel(phs.Inport)==1
                    ph=phs.Inport(1);
                    lh=get_param(ph,'Line');
                    [blk,port,h_blk,h_port]=soc.util.getHSBSrcBlk(lh);
                end
            end
        end
    end
end

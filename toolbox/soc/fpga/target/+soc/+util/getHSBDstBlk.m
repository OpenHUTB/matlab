




function[blks,ports,h_blks,h_ports]=getHSBDstBlk(h_line)
    [dst_blks,dst_ports,h_dst_blks,h_dst_ports]=soc.util.getDstBlk(h_line);
    if isempty(dst_blks)
        blks='';
        ports='';
        h_blks='';
        h_ports='';
    else
        blks={};
        ports={};
        h_blks=[];
        h_ports=[];
        for i=1:numel(dst_blks)
            this_blk=dst_blks{i};
            if startsWith(soc.util.getRefBlk(this_blk),{'hsblib_beta2','hsbhdllib','hwlogiciolib','socregisterchanneli2clib','xilinxsocad9361lib','xilinxsocvisionlib','hwlogicconnlib','socmemlib','xilinxrfsoclib','soclib_beta'})
                blks{end+1}=dst_blks{i};
                ports{end+1}=dst_ports{i};
                h_blks(end+1)=h_dst_blks(i);
                h_ports(end+1)=h_dst_ports(i);
            else
                if strcmpi(get_param(this_blk,'BlockType'),'subsystem')
                    if strcmpi(get_param(this_blk,'Variant'),'on')
                        active_blk=get_param(this_blk,'ActiveVariantBlock');
                        active_blk_fullname=getfullname(active_blk);
                        if startsWith(soc.util.getRefBlk(active_blk_fullname),{'hsblib_beta2','hsbhdllib','hwlogiciolib','hwlogicconnlib','socmemlib','xilinxrfsoclib','soclib_beta'})
                            dst_port_num=get_param(h_dst_ports(i),'PortNumber');
                            blk=active_blk_fullname;
                            port_cell=find_system(active_blk,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Inport');
                            port_name=get_param(port_cell{dst_port_num},'Name');
                            h_blk=get_param(active_blk,'Handle');
                            h_port_all=get_param(active_blk,'PortHandles');
                            h_port=h_port_all.Inport(dst_port_num);
                            blks{end+1}=blk;
                            ports{end+1}=port_name;
                            h_blks(end+1)=h_blk;
                            h_ports(end+1)=h_port;
                        end
                    else


                        connected_port=find_system(this_blk,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','Inport','Port',num2str(get_param(h_dst_ports(i),'PortNumber')));
                        if~isempty(connected_port)
                            phs=get_param(connected_port{1},'PortHandles');
                            lh=get_param(phs.Outport,'Line');
                            [recblks,recports,rech_blks,rech_ports]=soc.util.getHSBDstBlk(lh);
                            if~isempty(recblks)
                                blks=[blks,recblks];
                                ports=[ports,recports];
                                h_blks=[h_blks,rech_blks];
                                h_ports=[h_ports,rech_ports];
                            end
                        end
                    end
                elseif strcmpi(get_param(this_blk,'BlockType'),{'Inport'})
                    phs=get_param(this_blk,'PortHandles');
                    if numel(phs.Outport)==1
                        ph=phs.Outport(1);
                        lh=get_param(ph,'Line');
                        [recblks,recports,rech_blks,rech_ports]=soc.util.getHSBDstBlk(lh);
                        if~isempty(recblks)
                            blks=[blks,recblks];%#ok<*AGROW>
                            ports=[ports,recports];
                            h_blks=[h_blks,rech_blks];
                            h_ports=[h_ports,rech_ports];
                        end
                    end
                end
            end
        end

        if isempty(blks)
            blks='';
            ports='';
            h_blks='';
            h_ports='';
        end
    end
end

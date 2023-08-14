function[conn_pairs]=getConnections(vendor,sys,dut,intfInfo)





    conn_pairs={};

    allLine=find_system(sys,'SearchDepth',1,'findAll','on','type','line');

    for i=1:numel(allLine)
        this_line=allLine(i);
        [src_blk,src_port,h_src_blk,~]=soc.util.getSrcBlk(this_line);
        [dst_blks,dst_ports,h_dst_blks,~]=soc.util.getDstBlk(this_line);
        if~isempty(dst_blks)&&~isempty(src_blk)
            for j=1:numel(h_dst_blks)
                if(is_hsblib(h_src_blk)||is_dut(h_src_blk,dut))&&...
                    (is_hsblib(h_dst_blks(j))||is_dut(h_dst_blks(j),dut))


                    if is_hsblib(h_src_blk)
                        src_io=soc.util.hsbport2fpgaio(vendor,src_blk,src_port,intfInfo);

                        if contains(src_io,{'axim_w','axim_r'})
                            src_io='';
                        end
                    else
                        src_io=soc.util.dutport2fpgaio(vendor,src_blk,src_port,intfInfo);
                    end

                    if is_hsblib(h_dst_blks(j))
                        dst_io=soc.util.hsbport2fpgaio(vendor,dst_blks{j},dst_ports{j},intfInfo);

                        if contains(dst_io,{'axim_w','axim_r'})
                            dst_io='';
                        end


                        if strcmpi(dst_io,{'interrupt'})
                            dst_io='';
                        end
                    else
                        dst_io=soc.util.dutport2fpgaio(vendor,dst_blks{j},dst_ports{j},intfInfo);
                    end

                    if~isempty(src_io)&&~isempty(dst_io)
                        conn_pairs{end+1}=src_io;%#ok<AGROW>
                        conn_pairs{end+1}=dst_io;%#ok<AGROW>
                    end
                end
            end
        end
    end


    conn_pairs=rm_redunant_pairs(conn_pairs);

end

function val=is_hsblib(h_blk)
    blk_ref=soc.util.getRefBlk(h_blk);
    val=strncmpi(blk_ref,'hsbhdllib/',10)...
    ||strncmpi(blk_ref,'hwlogiciolib/',13)...
    ||strncmpi(blk_ref,'hwlogicconnlib/',15)...
    ||strncmpi(blk_ref,'hsblib_beta2/',13)...
    ||strncmpi(blk_ref,'soclib_beta/',12)...
    ||strncmpi(blk_ref,'socmemlib/',10)...
    ||strcmpi(blk_ref,'xilinxsocad9361lib/AD9361Rx')...
    ||strcmpi(blk_ref,'xilinxsocad9361lib/AD9361Tx')...
    ||soc.internal.isSoCBCustomIPBlk(h_blk)...
    ||strncmpi(blk_ref,'xilinxrfsoclib/',15)...
    ||strcmpi(blk_ref,'xilinxsocaudiocodeclib/ADAU1761 Codec')...
    ||strcmpi(get_param(h_blk,'BlockType'),'Inport')...
    ||strcmpi(get_param(h_blk,'BlockType'),'Outport');
end

function val=is_dut(h_blk,dut)
    blk_name=get_param(h_blk,'Name');
    val=any(strcmpi(blk_name,dut));
end

function outp_pairs=rm_redunant_pairs(inp_pairs)
    outp_pairs={};
    for i=1:2:numel(inp_pairs)
        if~any(all(ismember(outp_pairs,{inp_pairs{i},inp_pairs{i+1}}),2))
            outp_pairs(end+1,:)={inp_pairs{i},inp_pairs{i+1}};%#ok<AGROW> 
        end
    end
    outp_pairs=reshape(outp_pairs',1,[]);
end
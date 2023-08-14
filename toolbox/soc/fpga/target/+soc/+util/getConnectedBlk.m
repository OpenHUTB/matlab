function[blks,ports,h_blks,h_ports]=getConnectedBlk(this_port)

    [blk_name,port_name]=fileparts(this_port);
    h_all_ports=get_param(blk_name,'PortHandles');
    h_inp=h_all_ports.Inport;
    h_outp=h_all_ports.Outport;

    if strcmpi(get_param(blk_name,'BlockType'),'subsystem')
        io_type=get_param(this_port,'BlockType');
        port_num=str2double(get_param(this_port,'Port'));
    elseif strcmpi(get_param(blk_name,'BlockType'),'matlabsystem')
        [io_type,port_num]=soc.util.getSystemBlkPortTypeNum(blk_name,port_name);
    end

    if strncmpi(io_type,'in',2)
        h_this_port=h_inp(port_num);
        h_line=get_param(h_this_port,'Line');
        [blks,ports,h_blks,h_ports]=soc.util.getSrcBlk(h_line);
    elseif strncmpi(io_type,'out',3)
        h_this_port=h_outp(port_num);
        h_line=get_param(h_this_port,'Line');
        [blks,ports,h_blks,h_ports]=soc.util.getDstBlk(h_line);
    end

end
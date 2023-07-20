function[subsystem,source_ports]=HtoIL_collect_source_ports(block,port_names)













    blockName=get_param(block,'Name');

    Simulink.BlockDiagram.createSubsystem(block);
    subsystem=get_param(block,'Parent');
    set_param(subsystem,'Name',blockName);

    subsystem=get_param(block,'Parent');

    block_connections=get_param(block,'PortConnectivity');




    for i=1:length(block_connections)


        port_block=block_connections(i).DstBlock;
        if length(port_block)>1||port_block==block

            port_index=find(port_block~=block,1);
            if isempty(port_index)




                new_block=add_block('built-in/pmioport',...
                [subsystem,'/Conn'],'MakeNameUnique','on');
                new_block_port=HtoIL_collect_destination_ports(new_block,1);

                add_line(subsystem,new_block_port,block_connections(i).DstPort(1),'autorouting','on');


                block_connections=get_param(block,'PortConnectivity');
                port_block=block_connections(i).DstBlock;


                port_index=find(port_block~=block,1);
            end
        else
            port_index=1;
        end

        source_ports(i)=block_connections(i).DstPort(port_index);




        set_param(port_block(port_index),'Name',port_names{i});

    end


    for i=1:length(block_connections)
        DstPorts=block_connections(i).DstPort;
        for j=1:length(DstPorts)
            Line=get_param(DstPorts(j),'Line');
            if Line~=-1
                delete_line(get_param(DstPorts(j),'Line'));
            end
        end
    end


end

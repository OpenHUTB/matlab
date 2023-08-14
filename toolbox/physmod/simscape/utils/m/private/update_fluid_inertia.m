function out=update_fluid_inertia(hBlock)









    port_names={'A','B'};


    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);


    connections.destination_ports=connections.source_ports(end);
    connections.source_ports(end)=[];


    set_param(hBlock,'Commented','on')


    removed_block_warning.subsystem=getfullname(hBlock);

    pipe_hyperlink='<a href= "matlab: load_system( ''''fl_lib'''' ); open_system( ''''fl_lib/Isothermal Liquid/Elements'''' ); hilite_system( ''''fl_lib/Isothermal Liquid/Elements/Pipe (IL)'''' )" >Pipe (IL) block</a>';
    removed_block_warning.messages={['Consider modeling fluid inertia with a ',pipe_hyperlink,'.']};

    out.connections=connections;
    out.removed_block_warning=removed_block_warning;

end




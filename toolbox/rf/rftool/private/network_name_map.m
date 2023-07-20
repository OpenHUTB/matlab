function object=network_name_map(networktype)




    nw_names={'Cascaded Network';'Series Connected Network';...
    'Hybrid Connected Network';'Hybrid G Connected Network';...
    'Parallel Connected Network'};
    rfckt_objects={'rfckt.cascade';'rfckt.series';...
    'rfckt.hybrid';'rfckt.hybridg';'rfckt.parallel'};

    idx=strcmp(nw_names,networktype);
    if any(idx)
        object=eval(rfckt_objects{idx});
    else
        object=[];
    end

end
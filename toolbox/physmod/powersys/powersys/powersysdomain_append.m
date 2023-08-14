function powersysdomain_append(system)








    [r,n,append_independent_networks]=powersysdomain_netlist('get');

    if append_independent_networks
        powersysdomain_start(1);
    end
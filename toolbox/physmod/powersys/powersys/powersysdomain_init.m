function powersysdomain_init(mdl)







    [a,b,append_independent_networks]=powersysdomain_netlist('get');
    if append_independent_networks==2

        Append=1;
    else
        Append=0;
    end
    powersysdomain_netlist('clear',Append);
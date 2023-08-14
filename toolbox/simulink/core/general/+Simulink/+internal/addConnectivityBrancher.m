function addConnectivityBrancher(hierStrings,destination)




    h=add_block('built-in/SimscapeBus',destination);
    set_param(h,'hierStrings',hierStrings);



end

function key=nesl_solverkey(solver)




    hBlock=get_param(solver,'Handle');
    fullname=getfullname(hBlock);
    key=pmsl_sanitizename(fullname);

end

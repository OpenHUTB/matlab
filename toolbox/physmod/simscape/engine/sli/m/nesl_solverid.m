function id=nesl_solverid(solver)






    solver=get_param(solver,'Handle');
    sid=get_param(solver,'SID');
    root=bdroot(solver);
    rootName=get_param(root,'Name');
    id=[rootName,'_',sprintf('%x',pm_hash('crc',sid))];

end

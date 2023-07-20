function setNeverSavedParameters(solverConfigBlock)












    pp=simscape.internal.solverParametersNeverSaved;
    if isempty(pp)
        return
    end
    vv=get(NetworkEngine.SolverParameters,pp);


    ll=cellfun(@islogical,vv);
    if nnz(ll)>0
        tf=[vv{ll}];
        onoff=cell(size(tf));
        onoff(tf)={"on"};
        onoff(~tf)={"off"};
        vv(ll)=onoff;
    end


    pv=[pp(:)';string(vv(:))'];


    rootSys=pmsl_bdroot(solverConfigBlock);
    libraryLockState=get_param(rootSys,'Lock');
    if strcmp(libraryLockState,'on')
        set_param(rootSys,'Lock','off');
        C=onCleanup(@()set_param(rootSys,'Lock',libraryLockState));
    end


    set_param(solverConfigBlock,pv{:});
end

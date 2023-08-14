function cleanup=getConfigSetAdapterLockGuard(cs)








    cleanup=[];
    if isempty(cs)
        return;
    end





    adp=cs.getDialogController.csv2;
    if isa(adp,'configset.internal.data.ConfigSetAdapter')
        adp.lock;
        cleanup=onCleanup(@()adp.flush);
    end
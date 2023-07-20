function me=getExplorer(~)






    persistent sls;
    mlock;

    if isa(sls,'SigLogSelector.explorer')
        me=sls;
        return;
    end

    daRoot=DAStudio.Root;
    me=daRoot.find('-isa','SigLogSelector.explorer');
    if~isa(me,'SigLogSelector.explorer')
        me=[];
    end

    sls=me;
end

function CopyParamsToGlobalPool(~)






    hDriver=hdlcurrentdriver;
    slpropval=hDriver.getCPObj;
    PersistentHDLPropSet(copy(slpropval));
    hDriver.setParameter('entitynamelist',[]);
    hDriver.setParameter('entitypathlist',[]);
    hDriver.setParameter('entityportlist',[]);
    hDriver.setParameter('entityarchlist',[]);

    hDriver.setParameter('lasttopleveltargetlang','');
    hDriver.setParameter('lasttoplevelname','');
    hDriver.setParameter('lasttoplevelports','');
    hDriver.setParameter('lasttoplevelportnames','');
    hDriver.setParameter('lasttopleveldecls','');
    hDriver.setParameter('lasttoplevelinstance','');
    hDriver.setParameter('lasttopleveltimestamp','');

    hDriver.setParameter('vhdl_package_required',false);
end



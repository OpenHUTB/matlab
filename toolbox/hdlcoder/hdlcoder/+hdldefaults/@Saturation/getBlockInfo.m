function[lowerLimit,upperLimit,rndMode,satMode]=getBlockInfo(~,hC)


    slbh=hC.SimulinkHandle;
    ul_val=getResolvedInfo(slbh,'UpperLimit');
    ll_val=getResolvedInfo(slbh,'LowerLimit');

    rndMode=get_param(slbh,'RndMeth');
    satMode='saturate';

    tp=hC.SLOutputSignals(1).Type;


    u_limit_t=pirelab.getTypeInfoAsFi(tp,'Nearest',satMode,ul_val,false);
    l_limit_t=pirelab.getTypeInfoAsFi(tp,'Nearest',satMode,ll_val,false);

    if isfloat(u_limit_t)

        u_limit=u_limit_t;
        l_limit=l_limit_t;
    else


        user_fm=pirelab.getFimathFromProps(satMode,rndMode);
        u_limit=fi(u_limit_t,numerictype(u_limit_t),user_fm);
        l_limit=fi(l_limit_t,numerictype(l_limit_t),user_fm);
    end

    lowerLimit=l_limit';
    upperLimit=u_limit';
end


function val=getResolvedInfo(block,prop)

    prop_val=get_param(block,prop);
    val=slResolve(prop_val,block);
end

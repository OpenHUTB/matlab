function[rndMode,satMode]=getBlockInfo(this,hC)



    slbh=hC.SimulinkHandle;

    rndMode=get_param(slbh,'RndMeth');
    satMode=get_param(slbh,'DoSatur');

end


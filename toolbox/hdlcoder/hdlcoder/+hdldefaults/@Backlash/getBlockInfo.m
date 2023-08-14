function[backlashWidth,initialOutput]=getBlockInfo(~,hC)


    slbh=hC.SimulinkHandle;
    width=getResolvedInfo(slbh,'BacklashWidth');
    initialOutput=getResolvedInfo(slbh,'InitialOutput');



    backlashWidth=width./2;

end


function val=getResolvedInfo(block,prop)

    prop_val=get_param(block,prop);
    val=slResolve(prop_val,block);
end

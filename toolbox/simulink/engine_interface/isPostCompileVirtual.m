function value=isPostCompileVirtual(blk)









    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);
    obj=get_param(blk,'Object');
    value=obj.isPostCompileVirtual==true;
    delete(sess);
end

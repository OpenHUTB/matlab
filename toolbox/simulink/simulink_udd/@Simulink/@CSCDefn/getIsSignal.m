function isSig=getIsSignal(hCSCDefn,hData)




    assert(isa(hData,'Simulink.Data'));


    isSig=hCSCDefn.DataUsage.IsSignal;




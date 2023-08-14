function status=isVariantReducerActive()


































    [isInstalled,err]=slvariants.internal.utils.getVMgrInstallInfo('Variant Reducer');
    if~isInstalled
        throwAsCaller(err);
    end





    aliveSwitch=Simulink.variant.reducer.AliveSwitch.getInstance();
    status=aliveSwitch.getAliveStatus();

end

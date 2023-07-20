function baseValues=getSynchronousMachineAssociatedBases(blockName)





    import ee.internal.mask.getValue;


    baseValues=ee.internal.mask.getPerUnitMachineBase(blockName);
    b=baseValues.b;


    f=ee.internal.mask.getSynchronousMachineParametersFundamental(blockName);

    switch getValue(blockName,'fieldCircuitParameterization_option','1')
    case int32(ee.enum.sm.fieldparameterization.voltage)
        baseEfd=getValue(blockName,'baseEfd','V');
        rc=ee.internal.perunit.MachineRotorCircuitBase('internal',b,f,'baseEfd',baseEfd);
        fd=ee.internal.perunit.MachineFieldCircuitBase('field',b,f,'baseEfd',baseEfd);
    case int32(ee.enum.sm.fieldparameterization.current)
        baseIfd=getValue(blockName,'baseIfd','A');
        rc=ee.internal.perunit.MachineRotorCircuitBase('internal',b,f,'baseIfd',baseIfd);
        fd=ee.internal.perunit.MachineFieldCircuitBase('field',b,f,'baseIfd',baseIfd);
    otherwise
        pm_error('physmod:ee:library:IntegerOption',getString(message('physmod:ee:library:comments:utils:mask:getSynchronousMachineAssociatedBases:error_SpecifyFieldCircuitValueRequiredToProduceRatedTerminalVol')),'1','2');
    end


    baseValues.b=b;
    baseValues.rc=rc;
    baseValues.fd=fd;

end
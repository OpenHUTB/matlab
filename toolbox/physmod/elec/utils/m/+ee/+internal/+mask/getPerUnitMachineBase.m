function baseValues=getPerUnitMachineBase(blockName)





    import ee.internal.mask.getValue;


    SRated=getValue(blockName,'SRated','V*A');
    VRated=getValue(blockName,'VRated','V');
    FRated=getValue(blockName,'FRated','Hz');
    nPolePairs=getValue(blockName,'nPolePairs','1');
    connection=ee.enum.Connection(getValue(blockName,'connection_option','1'));


    b=ee.internal.perunit.MachineBase(SRated,VRated,FRated,connection,nPolePairs);


    baseValues.b=b;

end
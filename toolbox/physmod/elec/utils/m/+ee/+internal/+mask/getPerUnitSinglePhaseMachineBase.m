function baseValues=getPerUnitSinglePhaseMachineBase(blockName)





    import ee.internal.mask.getValue;


    SRated=getValue(blockName,'SRated','V*A');
    VRated=getValue(blockName,'VRated','V');
    FRated=getValue(blockName,'FRated','Hz');
    nPolePairs=getValue(blockName,'nPolePairs','1');


    b=ee.internal.perunit.SinglePhaseMachineBase(SRated,VRated,FRated,nPolePairs);


    baseValues.b=b;

end
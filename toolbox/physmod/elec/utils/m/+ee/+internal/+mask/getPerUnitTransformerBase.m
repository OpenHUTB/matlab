function baseValues=getPerUnitTransformerBase(blockName)





    import ee.internal.mask.getValue;


    SRated=getValue(blockName,'SRated','V*A');
    FRated=getValue(blockName,'FRated','Hz');
    VRated1=getValue(blockName,'VRated1','V');
    VRated2=getValue(blockName,'VRated2','V');
    connection1=ee.internal.mask.getTransformerConnection(blockName,1);
    connection2=ee.internal.mask.getTransformerConnection(blockName,2);

    if ee.internal.mask.isComponentTransformer2Winding(get_param(blockName,'ComponentPath'))

        b=ee.internal.perunit.TransformerBase(SRated,FRated,...
        VRated1,connection1,...
        VRated2,connection2);
    elseif ee.internal.mask.isComponentTransformer3Winding(get_param(blockName,'ComponentPath'))

        VRated3=getValue(blockName,'VRated3','V');
        connection3=ee.internal.mask.getTransformerConnection(blockName,3);

        b=ee.internal.perunit.TransformerBase(SRated,FRated,...
        VRated1,connection1,...
        VRated2,connection2,...
        VRated3,connection3);
    end

    baseValues.b=b;
end
function testRunner(testIDs,testTypes,parallelize)






    idMap=[testIDs,testTypes];

    try
        stm.internal.executeTests(int32(idMap),parallelize);
    catch err
        throw(err);
    end
end

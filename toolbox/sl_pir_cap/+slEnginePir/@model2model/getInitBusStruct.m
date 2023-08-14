function initBusStruct=getInitBusStruct(aThis,aMdl,aBus)




    try
        initBusStruct=Simulink.Bus.createMATLABStruct(aBus);
    catch
        dataAccessor=Simulink.data.DataAccessor.createForExternalData(aMdl);
        initBusStruct=Simulink.Bus.createMATLABStruct(aBus,[],1,dataAccessor);


    end
end




















function cb_ModelCloseFcn(block)






    map=Simulink.signaleditorblock.ListenerMap.getInstance;
    map.removeListener(num2str(getSimulinkBlockHandle(block),32));





    Simulink.signaleditorblock.SimulationData.removeSimulationDataFromHashMap(block);
end
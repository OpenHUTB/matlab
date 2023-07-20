function cb_DeleteFcn(block)





    map=Simulink.signaleditorblock.ListenerMap.getInstance;
    map.removeListener(num2str(getSimulinkBlockHandle(block),32));

end
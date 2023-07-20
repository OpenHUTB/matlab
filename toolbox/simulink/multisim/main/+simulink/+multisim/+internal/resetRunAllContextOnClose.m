function resetRunAllContextOnClose(studioComponent,modelHandle)





    dataId=simulink.multisim.internal.blockDiagramAssociatedDataId();
    bdData=Simulink.BlockDiagramAssociatedData.get(modelHandle,dataId);
    listener=addlistener(studioComponent,"Closed",@simulink.multisim.internal.unsetRunAllContextOnClose);
    bdData.CloseListeners=[bdData.CloseListeners,listener];
    Simulink.BlockDiagramAssociatedData.set(modelHandle,dataId,bdData);
end
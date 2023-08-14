function assignSimulinkDataTypeDlg(m3iObject,parentDlg)





    modelM3I=m3iObject.modelM3I;
    assert(modelM3I.RootPackage.size==1);


    modelName=autosar.mm.observer.ObserversDispatcher.findModelFromMetaModel(modelM3I);
    assert(~isempty(modelName),'Could not find a loaded Simulink model using m3iModel!');

    parentDlg.apply;

    simulinkTypeDlg=autosar.ui.metamodel.SimulinkDataType(parentDlg,m3iObject,modelName);
    DAStudio.Dialog(simulinkTypeDlg);

end



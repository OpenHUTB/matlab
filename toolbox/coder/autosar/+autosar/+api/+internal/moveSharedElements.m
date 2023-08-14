function moveSharedElements(modelName,dictionaryFile)






    srcM3IModel=autosar.api.Utils.m3iModel(modelName);
    dstM3IModel=Simulink.AutosarDictionary.ModelRegistry.getOrLoadM3IModel(dictionaryFile);




    autosarcore.unregisterListenerCB(srcM3IModel);
    rlCleanup=onCleanup(@()autosar.ui.utils.registerListenerCB(srcM3IModel));



    tSrc=M3I.Transaction(srcM3IModel);
    tDst=M3I.Transaction(dstM3IModel);

    mover=Simulink.metamodel.arplatform.ElementMover(srcM3IModel,dstM3IModel);
    mover.moveAllSharedElements();


    autosar.dictionary.internal.migrateXmlOptions(srcM3IModel,dstM3IModel,true);

    tSrc.commit();
    tDst.commit();


    autosar.api.Utils.setM3iModelDirty(modelName);

end



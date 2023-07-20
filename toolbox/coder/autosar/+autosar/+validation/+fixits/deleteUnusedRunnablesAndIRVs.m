function out=deleteUnusedRunnablesAndIRVs(modelName)





    mapping=autosar.api.Utils.modelMapping(modelName);
    m3iComp=autosar.api.Utils.m3iMappedComponent(modelName);
    m3iModel=autosar.api.Utils.m3iModel(modelName);

    tran=M3I.Transaction(m3iModel);
    autosar.ui.wizard.builder.Component.deleteUnusedM3IRunnables(mapping,m3iComp);
    autosar.ui.wizard.builder.Component.deleteUnusedM3IIRVs(mapping,m3iComp);
    tran.commit();

    out='Deleted unused runnables and irvs';



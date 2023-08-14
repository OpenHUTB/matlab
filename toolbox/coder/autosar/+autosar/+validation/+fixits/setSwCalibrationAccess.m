function out=setSwCalibrationAccess(model,portName,dataElementName)







    m3iDataElement=autosar.validation.AutosarUtils.findM3IDataElement(...
    model,portName,dataElementName);

    trans=M3I.Transaction(m3iDataElement.modelM3I);
    m3iDataElement.SwCalibrationAccess=Simulink.metamodel.foundation.SwCalibrationAccessKind.NotAccessible;
    trans.commit();

    out=DAStudio.message('autosarstandard:validation:SwCalibrationAccessSetToNotAccessible');



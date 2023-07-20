function compList=getCalibrationComponentNames(this)












    try

        cleanupObj=autosar.mm.util.MessageReporter.suppressWarningTrace();%#ok<NASGU>

        compList=p_getcomponentnames(this,'Parameter');
    catch Me

        autosar.mm.util.MessageReporter.throwException(Me);
    end


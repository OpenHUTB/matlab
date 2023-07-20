function compList=getSensorActuatorComponentNames(this)












    try

        cleanupObj=autosar.mm.util.MessageReporter.suppressWarningTrace();%#ok<NASGU>

        compList=p_getcomponentnames(this,'SensorActuator');
    catch Me

        autosar.mm.util.MessageReporter.throwException(Me);
    end


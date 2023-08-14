function compList=getApplicationComponentNames(this)












    try

        cleanupObj=autosar.mm.util.MessageReporter.suppressWarningTrace();%#ok<NASGU>

        compList=p_getcomponentnames(this,'Application');
    catch Me

        autosar.mm.util.MessageReporter.throwException(Me);
    end


function compList=getCompositionComponentNames(this)












    try

        cleanupObj=autosar.mm.util.MessageReporter.suppressWarningTrace();%#ok<NASGU>

        compList=p_getcomponentnames(this,'Composition');
    catch Me

        autosar.mm.util.MessageReporter.throwException(Me);
    end


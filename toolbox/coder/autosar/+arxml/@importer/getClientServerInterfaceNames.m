function compList=getClientServerInterfaceNames(this)












    try

        cleanupObj=autosar.mm.util.MessageReporter.suppressWarningTrace();%#ok<NASGU>

        compList=p_getcomponentnames(this,'csInterface');
    catch Me

        autosar.mm.util.MessageReporter.throwException(Me);
    end

% Helper method for setProperty of TestFile and TestSuite

function setPropertyHelper(obj, NV)

    if any(string({obj.Path}).endsWith('.m', 'IgnoreCase', true))
        me = MException(message('stm:ScriptedTest:FunctionNotSupported','setProperty'));
        throw(me);
    end
    idsToUpdate = stm.internal.testDefSafeTransaction(@helperSetProperties, obj, NV);
    stm.internal.updateUI(idsToUpdate);
end

function idsToUpdate = helperSetProperties(obj, NV)
    if isfield(NV, 'SetupCallback')
        stm.internal.setTestSuiteProperty(obj.id,'setupscript',NV.SetupCallback);
    end

    if isfield(NV, 'CleanupCallback')
        stm.internal.setTestSuiteProperty(obj.id,'cleanupscript',NV.CleanupCallback);
    end
    cbID = stm.internal.getCallbacksID(obj.id);
    idsToUpdate = {cbID,'Callbacks'};
end

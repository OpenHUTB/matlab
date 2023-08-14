% Helper method for getProperty of TestFile and TestSuite

function val = getPropertyHelper(obj, name)
    lname = lower(name);
    switch lname
        case{'setupcallback'}
            val = stm.internal.getTestSuiteProp(obj.id, 'SetupCallback');
        case{'cleanupcallback'}
            val = stm.internal.getTestSuiteProp(obj.id, 'CleanupCallback');
        case{'uuid'}
            val = stm.internal.getTestSuiteProp(obj.id, 'UUID');
        case{'revisionuuid'}
            val = stm.internal.getTestSuiteProp(obj.id, 'RevisionUUID');
        otherwise
            MException(message('stm:general:UnsupportedPropertyType',name)).throw;
    end
end

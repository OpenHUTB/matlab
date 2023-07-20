function deleteListeners(p)

    try %#ok<TRYNC>


        p.hListeners=internal.polariCommon.deleteListenerStruct(p.hListeners);
    end

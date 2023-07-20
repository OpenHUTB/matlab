function plcHandleError(ex)

    import plccore.common.PLCCoreException;

    if isa(ex,'plccore.common.PLCCoreException')
        fprintf(2,'%s\n\n',ex.msg);
    end

    rethrow(ex);
end



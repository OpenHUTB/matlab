function throwError(err_msg)

    import PLCCoder.extmode.PLCExtModeException;
    if isa(err_msg,'message')
        err_msg=err_msg.getString;
    end
    ex=PLCExtModeException(err_msg);
    throw(ex);
end

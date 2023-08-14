function handleError(ex)

    import PLCCoder.extmode.PLCExtModeException;

    if isa(ex,'PLCCoder.extmode.PLCExtModeException')
        error_cat=message('plccoder:extmode:ExtModeErrorCat');
        fprintf(2,'%s %s\n',error_cat.getString,ex.getMessage);
    else
        rethrow(ex);
    end
end



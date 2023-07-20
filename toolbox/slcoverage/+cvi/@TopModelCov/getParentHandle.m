




function pH=getParentHandle(handle)

    try
        pN=get_param(handle,'Parent');
        pH=get_param(pN,'Handle');
    catch MEx

        pH=0;
    end

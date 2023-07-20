function res=cv_get_param(handle,param)


    res=[];
    try
        if ishandle(handle)
            res=get_param(handle,param);
        end
    catch Mex %#ok<NASGU>
    end


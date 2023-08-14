function handle=safe_get_handle(pathname)



    try
        handle=get_param(pathname,'handle');
    catch Mex %#ok<NASGU>
        handle=0;
    end

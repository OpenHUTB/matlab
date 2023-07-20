function result=is_valid_path(bpath)



    if~ischar(bpath)
        result=false;
        return
    end


    parentPath=fileparts(bpath);

    try
        get_param(parentPath,'Handle');
        result=true;
    catch invalidblock %#ok<NASGU>
        result=false;
        return
    end


    try
        get_param(bpath,'Handle');
        result=false;
    catch invalidblock %#ok<NASGU>
        result=true;
    end


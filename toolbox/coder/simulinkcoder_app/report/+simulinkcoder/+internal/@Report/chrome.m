function chrome(obj)


    if ismac

        cmd='!/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome ';
    elseif isunix


    else


    end

    cmd=[cmd,' "',obj.getUrl,'"'];
    eval(cmd);


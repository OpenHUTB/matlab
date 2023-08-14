function chrome(obj)



    obj.firstSwitch;
    obj.prepareData;

    if ismac

        cmd='!/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome ';
    elseif isunix


    else


    end

    cmd=[cmd,' "',obj.DebugURL,'"'];
    eval(cmd);


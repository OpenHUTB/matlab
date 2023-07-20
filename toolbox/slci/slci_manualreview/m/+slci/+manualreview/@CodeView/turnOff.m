


function turnOff(obj)


    if~isempty(obj.cv_c)
        obj.cv_c.close;
    end


    if~isempty(obj.cv_hdl)
        obj.cv_hdl.close;
    end
end
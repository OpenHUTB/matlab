function turnOff(obj)




    if~isempty(obj.cv)
        obj.cv.close;
    end

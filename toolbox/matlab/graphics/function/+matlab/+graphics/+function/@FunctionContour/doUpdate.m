function doUpdate(hObj,us)



    if hObj.Visible=="off"
        return
    end

    data=hObj.getXYData(us);
    hObj.updateFill(us,data);
    hObj.updateLines(us,data);
end

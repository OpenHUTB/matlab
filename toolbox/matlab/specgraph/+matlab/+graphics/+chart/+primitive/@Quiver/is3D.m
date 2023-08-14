function d=is3D(hObj)


    d=false;
    if~isempty(hObj.ZData);
        d=true;
    end
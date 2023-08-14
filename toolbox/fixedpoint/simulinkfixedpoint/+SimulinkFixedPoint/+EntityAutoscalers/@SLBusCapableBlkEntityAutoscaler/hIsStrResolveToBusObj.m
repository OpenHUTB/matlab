function isBusObj=hIsStrResolveToBusObj(h,str,hBlk)






    str=hCleanBusName(h,str);

    if~isempty(sl('slbus_get_object_from_name',str,false))
        isBusObj=true;
        return
    end

    try
        busObj=slResolve(str,hBlk);

        if isa(busObj,'Simulink.Bus')
            isBusObj=true;
        else
            isBusObj=false;
        end

    catch
        isBusObj=false;
    end



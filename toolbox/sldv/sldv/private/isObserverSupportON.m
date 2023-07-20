function status=isObserverSupportON(sldv_option)




    status=false;
    if slfeature('ObserverSldv')==1
        status=true;
    end

    if strcmp(sldv_option.Mode,'DesignErrorDetection')
        status=true;
    end
end

function ensureServiceOn(obj)


    if~obj.serviceOn
        obj.init();
        obj.serviceOn=true;
    end


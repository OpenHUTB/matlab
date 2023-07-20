function resetAdapter(obj)







    cs=obj.getCS;
    if isempty(cs)
        return;
    end

    if obj.inReset
        return;
    end

    obj.inReset=true;
    c=onCleanup(@()loc_cleanup(obj));


    obj.compList=[];


    obj.tlcCreated=false;

    obj.setupTLC(cs);

    if obj.serviceOn

        obj.init();


        obj.refresh();
    end

    function loc_cleanup(obj)
        obj.inReset=false;


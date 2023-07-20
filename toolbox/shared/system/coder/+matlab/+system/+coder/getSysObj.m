function ret=getSysObj(obj)








    className=class(obj);

    ret=get(obj);


    mc=meta.class.fromName(className);
    mp=mc.PropertyList;





    pubprops=findobj(mp,'Hidden',true,'GetAccess','public','SetAccess','public');
    totalProps=numel(pubprops);

    for id=1:totalProps
        prop=pubprops(id);
        val=get(obj,prop.Name);


        ret.(prop.Name)=val;
    end

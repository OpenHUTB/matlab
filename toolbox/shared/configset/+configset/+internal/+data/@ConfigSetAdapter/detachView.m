function detachView(obj)




    obj.viewCount=obj.viewCount-1;


    if obj.viewCount<=0
        host=obj.Host;
        if ishandle(host)
            host.csv2=[];
        end
    end


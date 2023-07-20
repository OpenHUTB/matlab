function update(obj,~,eventData)




    data=eventData.data;
    action=data.action;

    switch action
    case 'update'
        params=data.params;
        obj.params=union(obj.params,params);



        if obj.isWebPageReady
            obj.updateCallback();
        end

    case 'refresh'
        obj.refresh();

    case 'removeError'
        name=data.params;
        obj.removeError(name,[]);

    case 'updateOverride'
        obj.updateOverride(data.list);
    end


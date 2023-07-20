function init(obj)




    mlock;
    persistent id

    if isempty(id)
        id=0;
    end

    id=id+1;
    obj.ID=sprintf('/csview%d',id);
    obj.errorMap=containers.Map;


    co=configset.dialog.Connector.getInstance();
    obj.fConnectorListener=event.listener(co,'Event',@obj.actionDispatcher);


    obj.ts=datestr(now,'HH:MM:SS');

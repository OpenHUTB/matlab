





















function createAndNotifyExtTrigger(obj,type,varargin)


    isValid=checkIfValidObj(obj);

    if~isValid
        return;
    end

    data=struct();
    switch type
    case 'warningDialog'



        data.Message=varargin{1};
        data.Title=varargin{2};

        evtData=lidar.internal.lidarViewer.events.ExternalTriggerEventData(...
        1,data);
        notify(obj,'ExternalTrigger',evtData);


    case 'progressBar'

        data.Message=varargin{1};
        data.Title=varargin{2};

        data.Progress=varargin{3};

        evtData=lidar.internal.lidarViewer.events.ExternalTriggerEventData(...
        2,data);
        notify(obj,'ExternalTrigger',evtData);

    case 'bringToFront'
        evtData=lidar.internal.lidarViewer.events.ExternalTriggerEventData(...
        3);
        notify(obj,'ExternalTrigger',evtData);
    end
end


function isValid=checkIfValidObj(obj)
    isValid=false;
    for i=1:numel(metaclass(obj).EventList)
        if isequal(metaclass(obj).EventList(i).Name,'ExternalTrigger')
            isValid=true;
            break;
        end
    end
end
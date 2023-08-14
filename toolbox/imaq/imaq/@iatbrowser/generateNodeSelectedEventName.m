function[eventName,nodeClass]=generateNodeSelectedEventName(nodeObject)



















    nodeCompleteClass=class(nodeObject);
    nodeClass=regexp(nodeCompleteClass,'.*\.(.*)','tokens');
    nodeClass=nodeClass{1}{1};
    eventName=[nodeClass,'Selected'];
    eventName(1)=lower(eventName(1));

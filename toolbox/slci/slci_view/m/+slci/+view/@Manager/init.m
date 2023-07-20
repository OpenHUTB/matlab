


function init(obj)

    if~obj.fInitialized


        obj.fViews=containers.Map('KeyType','char','ValueType','any');


        obj.fData=containers.Map('KeyType','double','ValueType','any');


        obj.configureContexts;


        obj.fInitialized=true;
    end
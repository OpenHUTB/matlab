


function init(obj)

    if~obj.fInitialized


        obj.fManualReviews=containers.Map('KeyType','char','ValueType','any');


        obj.fCodeViews=containers.Map('KeyType','char','ValueType','any');


        obj.fData=containers.Map('KeyType','double','ValueType','any');


        obj.fInitialized=true;

    end
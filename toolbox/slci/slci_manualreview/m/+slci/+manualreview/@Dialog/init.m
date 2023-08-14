


function init(obj)

    path='/toolbox/slci/slci_manualreview/web/';
    obj.setUrl([path,'manualReview.html']);
    obj.setDebugUrl([path,'manualReview-debug.html']);


    obj.fCodeLanguage='c';


    obj.fData=containers.Map('KeyType','char','ValueType','any');

    id=slci.view.Studio.generateClientID;
    obj.setChannel(['/slci_manualview_',id]);


    obj.subscribe(message.subscribe(obj.getChannel,@obj.receive));

end



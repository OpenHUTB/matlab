



function init(obj)


    path='/toolbox/slci/slci_view/web/';
    obj.setUrl([path,'modelmanager.html']);
    obj.setDebugUrl([path,'modelmanager-debug.html']);

    id=slci.view.Studio.generateClientID;
    obj.setChannel(['/slciview_modelmanager_',id]);


    obj.subscribe(message.subscribe(obj.getChannel,@obj.receive));



end

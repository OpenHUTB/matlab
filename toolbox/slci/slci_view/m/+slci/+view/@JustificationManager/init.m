



function init(obj)


    path='/toolbox/slci/slci_view/web/';
    obj.setUrl([path,'justificationmanager.html']);
    obj.setDebugUrl([path,'justificationmanager-debug.html']);

    id=slci.view.Studio.generateClientID;
    obj.setChannel(['/slciview_justificationmanager_',id]);


    obj.subscribe(message.subscribe(obj.getChannel,@obj.receive));



end

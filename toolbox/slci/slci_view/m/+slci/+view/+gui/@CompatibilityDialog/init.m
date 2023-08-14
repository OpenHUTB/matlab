


function init(obj)

    path='/toolbox/slci/slci_view/web/';
    obj.setUrl([path,'compatibility.html']);
    obj.setDebugUrl([path,'compatibility-debug.html']);

    id=slci.view.Studio.generateClientID;
    obj.setChannel(['/slciview_compatibility_',id]);


    obj.subscribe(message.subscribe(obj.getChannel,@obj.receive));
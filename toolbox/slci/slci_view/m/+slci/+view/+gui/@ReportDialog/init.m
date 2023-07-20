


function init(obj)

    path='/toolbox/slci/slci_view/web/';
    obj.setUrl([path,'report.html']);
    obj.setDebugUrl([path,'report-debug.html']);

    id=slci.view.Studio.generateClientID;
    obj.setChannel(['/slciview_report_',id]);


    obj.subscribe(message.subscribe(obj.getChannel,@obj.receive));
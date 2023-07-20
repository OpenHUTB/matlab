



function init(obj,varargin)

    path='/toolbox/slci/slci_view/web/';
    obj.setUrl([path,'justification.html']);
    obj.setDebugUrl([path,'justification-debug.html']);

    if(~isempty(varargin))
        id=varargin{1};
    else
        id=slci.view.Studio.generateClientID;
    end
    obj.setChannel(['/slciview_resultreview_',id]);



    obj.cacheDataManagerObj(obj.getDataManager);


    obj.subscribe(message.subscribe(obj.getChannel,@obj.receive));


    if~isempty(obj.getStudio)
        c=obj.getStudio.getService('GLUE2:ActiveEditorChanged');
        obj.fRegisterCallbackId=c.registerServiceCallback(@obj.onEditorChanged);
    end

end

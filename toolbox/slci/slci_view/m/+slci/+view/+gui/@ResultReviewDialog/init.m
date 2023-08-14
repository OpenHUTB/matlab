



function init(obj)

    obj.fBlockData=containers.Map('KeyType','char','ValueType','any');
    obj.fCodeSliceData={};
    obj.fInterfaceData={};
    obj.fTempVarData={};
    obj.fUtilFuncData={};

    path='/toolbox/slci/slci_view/web/';
    obj.setUrl([path,'resultreview.html']);
    obj.setDebugUrl([path,'resultreview-debug.html']);

    id=slci.view.Studio.generateClientID;
    obj.setChannel(['/slciview_resultreview_',id]);
    obj.setResultReviewID(id);


    obj.subscribe(message.subscribe(obj.getChannel,@obj.receive));


    if~isempty(obj.getStudio)
        c=obj.getStudio.getService('GLUE2:ActiveEditorChanged');
        obj.fRegisterCallbackId=c.registerServiceCallback(@obj.onEditorChanged);
    end

end



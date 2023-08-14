function url=getUrl(obj,input)




    path='toolbox/shared/slmleditor/web/';
    if obj.debug
        url=connector.getUrl([path,'index-debug.html']);
    else
        url=connector.getUrl([path,'index.html']);
    end

    if isnumeric(input)
        objectId=input;
    else
        objectId=obj.getObjectId(input);
    end


    sid=slmle.internal.getSID(objectId);
    query=sprintf('sid=%s',sid);
    url=[url,'&',query];

    query=sprintf('objectId=%d',objectId);
    url=[url,'&',query];

    type=slmle.internal.checkMLFBType(objectId);
    query=sprintf('type=%s',type);
    url=[url,'&',query];

    sfx=Stateflow.App.IsStateflowApp(objectId);
    query=sprintf('sfx=%d',sfx);
    url=[url,'&',query];

    modelH=get_param(bdroot,'Handle');
    if sfx
        [~,filepath]=Stateflow.App.Studio.isSfxModelAssociatedWithFileOnDisk(modelH);
    else
        filepath=get_param(modelH,'FileName');
    end
    query=sprintf('path=%s',filepath);
    url=[url,'&',query];



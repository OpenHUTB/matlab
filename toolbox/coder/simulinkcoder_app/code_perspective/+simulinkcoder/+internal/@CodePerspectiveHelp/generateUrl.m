function url=generateUrl(obj)


    path='/toolbox/coder/simulinkcoder_app/code_perspective/ui/';
    if obj.debugMode
        url=connector.getUrl([path,'index-debug.html']);
    else
        url=connector.getUrl([path,'index.html']);
    end

    url=[url,'&type=help&channel=',obj.channel];

    src=simulinkcoder.internal.util.getSource();
    mdl=src.modelName;
    if isempty(mdl)

    else
        url=[url,'&model=',mdl];
        target=obj.getTarget(mdl);
        url=[url,'&target=',target];
    end
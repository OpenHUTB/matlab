function url=generateUrl(obj)


    path='/toolbox/coder/simulinkcoder_app/code_perspective/ui/';
    if obj.debugMode
        url=connector.getUrl([path,'index-debug.html']);
    else
        url=connector.getUrl([path,'index.html']);
    end

    url=[url,'&type=overlay&channel=',obj.channel];

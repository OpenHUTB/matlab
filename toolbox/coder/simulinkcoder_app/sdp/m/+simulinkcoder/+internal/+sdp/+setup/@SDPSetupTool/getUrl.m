function url=getUrl(obj)

    if obj.debug
        url=connector.getUrl(obj.app.getUrl());
    else
        url=connector.getUrl(obj.app.getUrl('toolbox/mdom/web/index.html',true));
    end

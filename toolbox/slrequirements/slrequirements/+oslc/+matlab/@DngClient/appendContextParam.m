function url=appendContextParam(url)

    if contains(url,'vvc.configuration')||contains(url,'oslc_config.context')
        return;
    end
    context=oslc.getCurrentContext();
    if~isempty(context)&&~isempty(context.uri)
        if contains(url,'=')
            url=[url,'&oslc_config.context=',urlencode(context.uri)];
        else
            url=[url,'?oslc_config.context=',urlencode(context.uri)];
        end
    end
end

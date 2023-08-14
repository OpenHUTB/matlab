function hilite(urls)





    if isempty(urls)
        return;
    end
    if~iscell(urls)
        urls={urls};
    end

    for i=1:length(urls)
        url=urls{i};
        h=Simulink.URL.parseURL(url);
        h.hilite;
    end
    Simulink.URL.setHilited(true);


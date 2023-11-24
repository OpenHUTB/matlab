function this=Browser

    mlock;
    persistent browserInstance;
    if isempty(browserInstance)
        browserInstance=iatbrowser.Browser;
        initialize(browserInstance,false);
    end

    this=browserInstance;

end
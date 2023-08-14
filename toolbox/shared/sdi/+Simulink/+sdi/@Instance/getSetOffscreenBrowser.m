function gui=getSetOffscreenBrowser(obj)

    mlock;
    persistent OFFSCREEN_BROWSER;
    if nargin>0
        OFFSCREEN_BROWSER=obj;
    elseif~isempty(OFFSCREEN_BROWSER)&&~isvalid(OFFSCREEN_BROWSER)
        OFFSCREEN_BROWSER=[];
    end
    gui=OFFSCREEN_BROWSER;
end

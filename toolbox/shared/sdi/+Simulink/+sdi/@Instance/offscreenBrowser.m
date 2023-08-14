function browser=offscreenBrowser(varargin)
    browser=Simulink.sdi.Instance.getSetOffscreenBrowser();
    if isempty(browser)||~Simulink.sdi.internal.OffscreenBrowser.isRunning()
        browser=Simulink.sdi.internal.OffscreenBrowser(varargin{:});
        Simulink.sdi.Instance.getSetOffscreenBrowser(browser);





        NUM_INIT_PAUSES=20;
        for idx=1:NUM_INIT_PAUSES
            locWait(0.2);
        end
    end
end


function locWait(val)
    pause(val);
drawnow
end

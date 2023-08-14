function supported=isClipboardSupported()




    supported=~matlab.internal.environment.context.isWebAppServer;
    if supported
        s=settings;
        supported=~s.matlab.ui.figure.ShowInMATLABOnline.ActiveValue;
    end

end

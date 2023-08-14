function flag=isMOTW()
    status=warning('query');

    try
        flag=strcmp(mls.internal.feature('graphicsAndGuis','status'),'on');
    catch
        flag=false;
    end
    warning(status);

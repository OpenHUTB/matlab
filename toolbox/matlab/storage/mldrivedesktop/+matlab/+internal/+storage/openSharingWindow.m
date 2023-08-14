function windowOpened=openSharingWindow(baseWindowUrl,type,cert)







    mlock;

    [resizable,windowSize]=getWindowSize(type);

    switch type
    case 'manage'
        persistent existingWindowHandleManage;%#ok<*TLEV>
        persistent existingWindowHandleManageURL;
        existingWindowHandle=existingWindowHandleManage;
        existingBaseURL=existingWindowHandleManageURL;
    case 'links'
        persistent existingWindowHandleLinks;
        persistent existingWindowHandleLinksURL;
        existingWindowHandle=existingWindowHandleLinks;
        existingBaseURL=existingWindowHandleLinksURL;
    case 'offline'
        persistent existingWindowHandleOffline;
        persistent existingWindowHandleOfflineURL;
        existingWindowHandle=existingWindowHandleOffline;
        existingBaseURL=existingWindowHandleOfflineURL;
    end

    windowUrl=[char(baseWindowUrl.toString()),'&type=',type];




    if resizable
        windowUrl=[windowUrl,'&clientString=mw-resizable-desktop'];
    end

    windowOpened=false;

    if~isempty(existingWindowHandle)&&existingWindowHandle.isWindowValid
        try %#ok<TRYNC>



            if~isempty(existingBaseURL)&&(existingBaseURL==baseWindowUrl)


                bringToFront(existingWindowHandle);
                windowOpened=true;
            else


                close(existingWindowHandle);
            end
        end
    end

    if~windowOpened

        remoteDebugPort=0;

        if ismac
            windowType='FixedSize-Dialog';
        else
            windowType='FixedSize';
        end


        connector.ensureServiceOn();

        ww=matlab.internal.webwindow(...
        windowUrl,...
        'DebugPort',remoteDebugPort,...
        'Position',centerPosition(windowSize),...
        'WindowType',windowType,...
        'Certificate',cert);

        msgObj=message('MATLABDrive:desktop:sharing');
        ww.Title=getString(msgObj);
        show(ww);
        bringToFront(ww);

        windowOpened=true;
        existingBaseURL=baseWindowUrl;

        switch type
        case 'manage'
            existingWindowHandleManage=ww;
            existingWindowHandleManageURL=existingBaseURL;
        case 'links'
            existingWindowHandleLinks=ww;
            existingWindowHandleLinksURL=existingBaseURL;
        case 'offline'
            existingWindowHandleOffline=ww;
            existingWindowHandleOfflineURL=existingBaseURL;
        end
    end
end

function center=centerPosition(windowSize)
    screenSize=get(groot,'ScreenSize');
    screenSize=screenSize(3:4);
    center=[(screenSize-windowSize)/2,windowSize];
end

function[resizable,dims]=getWindowSize(type)
    resizable=false;
    switch type
    case 'offline'
        dims=[600,185];
    case 'links'
        [resizable,dims]=getWindowSizeFromWeb('links',600,300);
    case 'manage'
        [resizable,dims]=getWindowSizeFromWeb('users',600,422);
    end
end

function[resizable,dims]=getWindowSizeFromWeb(type,defaultX,defaultY)

    resizable=false;
    dims=[defaultX,defaultY];

    urlMgr=matlab.internal.UrlManager;
    jsonURL=urlMgr.MLDO+'/client/dimensions/initiateSharing.json';
    options=weboptions('ContentType','json');
    try

        rep=webread(jsonURL,options);


        iframesTable=struct2table(rep.iframes);


        typeIdx=find(strcmp(type,iframesTable.iframeName));


        widthIdx=strcmp('widthInPixels',iframesTable.Properties.VariableNames);
        heightIdx=strcmp('heightInPixels',iframesTable.Properties.VariableNames);

        x=str2double(iframesTable{typeIdx,widthIdx});
        y=str2double(iframesTable{typeIdx,heightIdx});

        assert(isnumeric(x)&&isnumeric(y));
        dims=[x,y];
        resizable=true;
    catch

    end

end

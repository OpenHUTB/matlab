function windowOpened=openRecentActivityWindow(baseWindowUrl,cert)

    persistent existingWindowHandle;
    mlock;

    windowOpened=false;

    if~isempty(existingWindowHandle)&&existingWindowHandle.isWindowValid
        try %#ok<TRYNC>


            bringToFront(existingWindowHandle);
            windowOpened=true;
        end
    end

    function handleWindowClosed(~,~)
        if~isempty(eccWnd)
            eccWnd.close();
        end
        ww.close();
    end

    if~windowOpened






        if isunix&&~ismac
            eccWnd=[];
        else
            eccWnd=matlab.internal.webwindow(connector.getUrl(''));
        end

        baseWindowUrl=matlab.net.URI(char(baseWindowUrl));
        windowUrl=addConnectorInfo(baseWindowUrl);



        windowSize=[370,480];
        remoteDebugPort=0;

        if ismac
            windowType='FixedSize-Dialog';
        else
            windowType='FixedSize';
        end

        ww=matlab.internal.webwindow(...
        windowUrl,...
        'DebugPort',remoteDebugPort,...
        'Position',centerPosition(windowSize),...
        'WindowType',windowType,...
        'Certificate',cert);

        msgObj=message('MATLABDrive:desktop:recent');
        ww.Title=getString(msgObj);
        show(ww);


        ww.CustomWindowClosingCallback=@handleWindowClosed;

        windowOpened=true;

        existingWindowHandle=ww;
    end
end

function windowUrl=addConnectorInfo(baseWindowUrl)


    connector.ensureServiceOn;


    mlPort=connector.securePort;


    nonce=connector.newNonce;

    connectorQuery='';
    if~isempty(baseWindowUrl.EncodedQuery)
        connectorQuery='&';
    end


    baseWindowUrl.EncodedQuery=baseWindowUrl.EncodedQuery+connectorQuery+...
    'ui=minimal&matlabPort='+mlPort+'&nonce='+nonce;

    windowUrl=char(baseWindowUrl);
end

function center=centerPosition(windowSize)
    screenSize=get(groot,'ScreenSize');
    screenSize=screenSize(3:4);
    center=[(screenSize-windowSize)/2,windowSize];
end

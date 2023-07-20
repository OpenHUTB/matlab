function[hFig,img_data]=snapshot(varargin)





















    try
        FROM_OPTIONS={'opened','active','comparison','custom'};
        TO_OPTIONS={'clipboard','file','image','figure'};


        p=inputParser;
        p.addParameter('from','opened',@(x)any(validatestring(x,FROM_OPTIONS)));
        p.addParameter('to','image',@(x)any(validatestring(x,TO_OPTIONS)));
        p.addParameter('filename','plots.png',@mustBeTextScalar);
        p.addParameter('settings',Simulink.sdi.CustomSnapshot,@(x)isa(x,'Simulink.sdi.CustomSnapshot'));
        p.addParameter('props',{},@iscell);
        p.addParameter('figure',[]);
        p.parse(varargin{:});
        params=p.Results;

        params.filename=validateAndUpdateFileExt(params.filename);

        [hFig,img_data]=doSnapshot(params);
    catch me
        me.throwAsCaller();
    end
end


function fname=validateAndUpdateFileExt(fname)
    fname=char(fname);
    [~,~,ext]=fileparts(fname);
    if isempty(fname)
        error(message('SDI:sdi:InvalidPNGFileName'));
    elseif isempty(ext)
        fname=[fname,'.png'];
    elseif~strcmpi(ext,'.png')
        error(message('SDI:sdi:InvalidPNGFileName'));
    end
end


function[clientID,client]=getClientID(params)
    import Simulink.sdi.internal.Util;
    clientID=int64(0);
    client=[];
    switch lower(params.from)
    case{'opened','active'}
        if Simulink.sdi.internal.WebGUI.debugMode()
            client=Util.getConnectedClient('sdi-debug');
        else
            client=Util.getConnectedClient('sdi');
        end

    case 'comparison'
        client=Util.getConnectedClient('SDIComparison');

    case 'custom'
        params.settings.updateClient();
        client=params.settings.getClient();
    end


    if~isempty(client)
        clientID=int64(str2double(client.ClientID));
    end
end


function[hFig,img_data]=doSnapshot(params)
    hFig=[];
    img_data=[];
    eng=Simulink.sdi.Instance.engine;


    if strcmpi(params.from,'opened')||strcmpi(params.from,'active')
        waitForClientToOpen(params);
    end


    [clientID,client]=getClientID(params);





    if~strcmpi(params.from,'custom')
        locWaitForPlottingToComplete(params,client,clientID);
    end


    bCopyActiveOnly=strcmpi(params.from,'active');
    if bCopyActiveOnly
        copyType='copySubplot';
    else
        copyType='all';
    end

    argList={};


    if strcmpi(params.from,'comparison')
        sigID=getPlottedComparisonSignal(eng.sigRepository);
        if sigID
            runID=getSignalRunID(eng.sigRepository,sigID);
            compareRunName=getCompareToRunName(eng.sigRepository,runID);
            dsr=Simulink.sdi.DiffSignalResult(sigID);
            ss=dsr.Status;
            if ss~=Simulink.sdi.ComparisonSignalStatus.WithinTolerance&&...
                ss~=Simulink.sdi.ComparisonSignalStatus.OutOfTolerance
                argList={'unplottedSignalID',sigID,'signalName',dsr.Name,...
                'comparisonStatus',string(ss),'compareRunName',compareRunName};
            end
        end
    end


    if strcmpi(params.to,'figure')
        hFig=eng.exportPlotToFigure(...
        num2str(clientID),0,copyType,argList{:},'figureProps',params.props);
        return
    end


    if strcmpi(params.to,'image')
        params.filename=[tempname,'.png'];
    elseif strcmpi(params.to,'clipboard')
        params.filename='';
    end


    Simulink.sdi.createSnapshot(clientID,bCopyActiveOnly,char(params.filename));


    if strcmpi(params.to,'file')
        sw=warning('off','MATLAB:imagesci:png:tooManyIDATsData');
        tmp=onCleanup(@()warning(sw));
        MAX_TRIES=20;
        nTries=0;
        isFileReady=false;
        while~isFileReady&&nTries<MAX_TRIES
            try
                img_data=imread(params.filename);
                isFileReady=true;
            catch ME %#ok<NASGU>
                isFileReady=false;
                pause(0.1);
            end
            nTries=nTries+1;
            if nTries>MAX_TRIES
                isFileReady=true;
            end
        end
    end


    if strcmpi(params.to,'image')
        pause(0.1);
        if exist(params.filename,'File')
            [hFig,img_data]=getImageFromFile(params.filename,params.props,params.figure);
            delete(params.filename);
        end
    end
end


function waitForClientToOpen(params)
    eng=Simulink.sdi.Instance.engine;
    checkedSigs=eng.sigRepository.getAllCheckedSignals('sdi',false);
    bCheckForPlotted=~isempty(checkedSigs);

    MAX_TRIES=20;
    for idx=1:MAX_TRIES
        [clientID,client]=getClientID(params);
        if clientID&&~isempty(client)
            if~bCheckForPlotted||hasPlottedSignals(client)
                return
            end
        end
        pause(0.3);
drawnow
    end
end


function ret=hasPlottedSignals(client)
    ret=false;
    numAxes=length(client.Axes);
    for idx=1:numAxes
        if~isempty(client.Axes(idx).DatabaseIDs)
            ret=true;
            return
        end
    end
end


function[hFig,img_data]=getImageFromFile(fname,props,hFig)


    warning('off','MATLAB:imagesci:png:tooManyIDATsData');
    MAX_TRIES=20;
    for idx=1:MAX_TRIES
        try
            img_data=imread(fname);
            break;
        catch ME %#ok<NASGU>
            pause(0.2);
        end
    end
    warning('on','MATLAB:imagesci:png:tooManyIDATsData');

    bFigPassedIn=~isempty(hFig);
    if~bFigPassedIn
        hFig=figure(props{:});
    else
        isVisible=hFig.Visible;
    end
    hAxes=axes('Parent',hFig,'Visible',hFig.Visible);




    sw=warning('off','all');
    tmp=onCleanup(@()warning(sw));
    hImg=imshow(img_data,'Parent',hAxes);%#ok<NASGU>
    if bFigPassedIn
        hFig.Visible=isVisible;
    end














end



























function locWaitForPlottingToComplete(params,client,clientID)
    if~isempty(client)
        isComparison=strcmpi(params.from,'comparison');
        Simulink.sdi.waitForPlottingOnClient(clientID,isComparison);
    end
end
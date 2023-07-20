function updateClient(this)


    MAX_RETRIES=50;
    for idx=1:MAX_RETRIES
        try
            client=this.getClient();
            if~isempty(client)
                clientID=int64(str2double(client.ClientID));


                locResizeWindow(this,client);


                mainClient=this.getClient(false);
                mainClientID=int64(str2double(mainClient.ClientID));
                bComparison=this.ComparisonSignalID~=0;
                repo=Simulink.sdi.Instance.engine.sigRepository;
                Simulink.sdi.notifyChangeTab(repo,double(bComparison),mainClientID);



                locResizeWindow(this,client);


                if~bComparison
                    Simulink.sdi.setSubPlotLayout(this.Rows,this.Columns,clientID);
                end


                if bComparison
                    locPlotComparison(this,clientID);
                else
                    [timeRange,dataRange]=locPlotSignals(this,client.ClientID);
                    locSetLimits(this,client,timeRange,dataRange);
                end
            end
        catch me %#ok<NASGU>


            locWait(0.2);
            continue
        end


        return
    end
end


function[timeRange,dataRange]=locPlotSignals(this,clientID)
    D_BUFFER=0.05;
    timeRange=[];
    dataRange=[];
    repo=Simulink.sdi.Instance.engine.sigRepository;

    plottedSigs=keys(this.Signals);
    numSigs=length(plottedSigs);
    if~numSigs
        opts=struct.empty();
    else
        opts(numSigs)=struct('id',int32(0),'plots',uint8.empty());
    end

    for idx=1:numSigs
        opts(idx).id=plottedSigs{idx};
        opts(idx).plots=this.Signals(plottedSigs{idx});
        sigTimeRange=repo.getSignalRange(plottedSigs{idx});
        dataRange=repo.getSignalDataRange(plottedSigs{idx});
        if idx<=length(this.YRange)&&isempty(this.YRange{idx})


            this.YRange{idx}=[dataRange(1)*(1-D_BUFFER),...
            dataRange(2)*(1+D_BUFFER)];
        end
        if isempty(timeRange)
            timeRange=sigTimeRange;
        else
            if sigTimeRange(1)<timeRange(1)
                timeRange(1)=sigTimeRange(1);
            end
            if sigTimeRange(2)>timeRange(2)
                timeRange(2)=sigTimeRange(2);
            end
        end
    end



    Simulink.sdi.plotSignalsOnClient(clientID,opts);
end


function locPlotComparison(this,clientID)
    Simulink.sdi.plotComparisonSignalOnClient(clientID,this.ComparisonSignalID);
end


function locSetLimits(this,client,timeRange,dataRange)
    import Simulink.sdi.internal.Util;
    T_BUFFER=1;
    D_BUFFER=1;
    for idx=1:length(client.Axes)
        plotIdx=locGetPlotIdxForAxes(client,idx);

        if~isempty(this.TimeSpan)
            client.Axes(idx).TimeSpan=this.TimeSpan;
            Util.waitForTimeSpanUpdate(client,idx,this.TimeSpan);
        elseif~isempty(timeRange)
            tRange=[timeRange(1),timeRange(2)];
            if isempty(this.YRange{plotIdx})
                if~isequal(dataRange(1),dataRange(2))

                    this.YRange{plotIdx}=[dataRange(1),dataRange(2)];
                else


                    this.YRange{plotIdx}=[dataRange(1)-D_BUFFER,...
                    dataRange(2)+D_BUFFER];
                end
            end
            if isequal(tRange(1),tRange(2))

                tRange(1)=tRange(1)-T_BUFFER;
                tRange(2)=tRange(2)+T_BUFFER;
            end
            client.Axes(idx).TimeSpan=tRange;
            Util.waitForTimeSpanUpdate(client,idx,tRange);
        end


        if plotIdx<=numel(this.YRange)&&~isempty(this.YRange{plotIdx})
            client.Axes(idx).YRange=double(this.YRange{plotIdx});
            Util.waitForYRangeUpdate(client,idx,double(this.YRange{plotIdx}));
        end
    end
end


function plotIdx=locGetPlotIdxForAxes(client,axesIdx)

    numPlots=length(client.Axes);
    plotIdx=1+numPlots-axesIdx;
end


function locResizeWindow(this,client)

    origSize=this.OffscreenUI.Size;
    if~isempty(client.Axes)
        origSize=client.Axes(1).AxesSize;
    end
    bNeedsPolling=~isequal(this.OffscreenUI.Size,[this.Width,this.Height]);
    this.OffscreenUI.setSize(this.Width,this.Height);


    if bNeedsPolling
        MAX_RETRIES=50;
        for idx=1:MAX_RETRIES
            try
                curSize=client.Axes(1).AxesSize;
                if~isequal(curSize,origSize)&&curSize(1)<=this.Width&&curSize(2)<=this.Height
                    return
                end
            catch me %#ok<NASGU>


            end
            locWait(0.2);
        end
    end






    persistent bFirstTime
    if isempty(bFirstTime)
        NUM_INIT_PAUSES=20;
        for idx=1:NUM_INIT_PAUSES
            locWait(0.2);
        end
        bFirstTime=false;
    end
end


function locWait(val)
    pause(val);
drawnow
end


function exportArrayPlotToFigure(hFig,clientId,rowIdx,colIdx,appInfo)
    sdiEngine=Simulink.sdi.Instance.engine;

    appInstanceID=0;
    if~isempty(appInfo)&&~isempty(appInfo.recordBlk)
        appInstanceID=get_param(appInfo.recordBlk,'AppInstanceID');
    end


    pluginMedatData=sdi_visuals.getPluginMetadata(clientId,rowIdx,colIdx);
    sigIDs=sdi_visuals.getCheckedSignalIDs(appInstanceID,rowIdx,colIdx);

    subplotID=8*(colIdx-1)+rowIdx;
    appInstanceID=sdi_visuals.getAppInstID(clientId);
    arrayplotPrefs=sdi_visuals.getVisualizationPreferences(appInstanceID,subplotID);


    plotFunctionHandle=@(sigID)plotOnSubplot(sdiEngine,hFig,pluginMedatData,...
    arrayplotPrefs,sigID);


    arrayfun(plotFunctionHandle,sigIDs,'UniformOutput',false);


    if~isempty(sigIDs)


        hLegend=legend(hFig.CurrentAxes,'show');
        if length(hLegend.String)>1



            for idx=1:length(hLegend.String)
                currString=hLegend.String{idx};
                hLegend.String{idx}=erase(currString,'getcolumn');
            end
        end
        hLegend.Interpreter='none';
        hLegend.Visible='on';
        hLegend.Location='northoutside';


        hFig.CurrentAxes.XLim=[arrayplotPrefs.limits.xMin,arrayplotPrefs.limits.xMax];
        hFig.CurrentAxes.YLim=[arrayplotPrefs.limits.yMin,arrayplotPrefs.limits.yMax];


        hFig.CurrentAxes.XGrid='on';
        hFig.CurrentAxes.YGrid='on';

        hFig.CurrentAxes.Box='on';
        hFig.CurrentAxes.Title.String='';
        hFig.CurrentAxes.XTickLabelMode='auto';
        hFig.CurrentAxes.YTickLabelMode='auto';
    end
end

function channelsCount=plotOnSubplot(sdiEngine,hFig,pluginMedatData,...
    arrayplotPrefs,sigID)

    if sdiEngine.sigRepository.getSignalIsActivelyStreaming(sigID)
        error(message('SDI:sdi:SendToFigWhileStreaming'));
    end


    xAxisIncrement=pluginMedatData.xAxisIncrement;
    xAxisOffset=pluginMedatData.xAxisOffset;


    sigObj=Simulink.sdi.getSignal(sigID);


    timePoints=numel(sigObj.Values.Time);
    if isfield(arrayplotPrefs.limits,'isCursorActive')&&...
        arrayplotPrefs.limits.isCursorActive
        timePoints=numel(find(sigObj.Values.Time<=...
        arrayplotPrefs.limits.currentCursorTime));
    end


    dataPoints=sigObj.Values.Data;


    dims=sigObj.Dimensions(1);

    isSignalSupported=length(sigObj.Dimensions)<3;

    if isSignalSupported


        if isnumeric(sigObj.Dimensions)&&length(sigObj.Dimensions)>1
            rows=sigObj.Dimensions(1);
            cols=sigObj.Dimensions(2);
            dataPoints=dataPoints(:,:,1:timePoints);
            reshapedData=reshape(dataPoints,rows,cols,timePoints);

            dataPoints=reshapedData(:,:,timePoints);
        elseif strcmpi(sigObj.Dimensions,'variable')


            timeVals=time2num(sigObj.Values.Time);
            timePoints=numel(timeVals);
            if(arrayplotPrefs.limits.isCursorActive)
                timePoints=numel(find(timeVals<=...
                arrayplotPrefs.limits.currentCursorTime));
            end
            dataPoints=dataPoints{timePoints}';
        else
            dataPoints=dataPoints(timePoints,:);
        end
    else

        createEmptyFigForUnsupportedSignal(sdiEngine,sigObj.ID,sigObj.Name);
        return;
    end


    if sigObj.getIsCollapsedMatrix()

        channels=xAxisOffset:xAxisIncrement:xAxisOffset+xAxisIncrement*(dims-1);
    elseif strcmpi(sigObj.Dimensions,'variable')
        channels=xAxisOffset:xAxisIncrement:xAxisOffset+xAxisIncrement*(length(dataPoints)-1);
    else

        channels=0;
    end


    channelsCount=channels(end);


    mFaceColor=getSignalLineColor(sdiEngine,sigID);


    lineWidth=getSignalLineWidth(sdiEngine,sigID);

    dataPointsReal=real(dataPoints);
    dataPointsImag=imag(dataPoints);
    switch(sigObj.ComplexFormat)
    case 'phase'
        dataPointsReal=angle(dataPoints)*(180/pi);
        dataPointsImag=[];
    case 'magnitude'
        dataPointsReal=abs(dataPoints);
        dataPointsImag=[];
    case 'magnitude-phase'
        dataPointsReal=abs(dataPoints)*(180/pi);
        dataPointsImag=angle(dataPoints);
    end


    switch(pluginMedatData.plotType)
    case 'bar'

        bar(channels,dataPointsReal,...
        'FaceColor',mFaceColor,...
        'EdgeColor',mFaceColor,...
        'LineWidth',lineWidth,...
        'DisplayName',sigObj.Name,...
        'ShowBaseLine',false);
        if(any(dataPointsImag))
            bar(channels,dataPointsImag,...
            'FaceColor',mFaceColor,...
            'EdgeColor',mFaceColor,...
            'LineWidth',lineWidth,...
            'DisplayName',sigObj.Name,...
            'ShowBaseLine',false);
        end

    case 'stair'

        stairs(channels,dataPointsReal,...
        'LineWidth',lineWidth,...
        'Color',mFaceColor,...
        'DisplayName',sigObj.Name);
        if(any(dataPointsImag))
            stairs(channels,dataPointsImag,...
            'LineWidth',lineWidth,...
            'Color',mFaceColor,...
            'DisplayName',sigObj.Name);
        end

    case 'line'

        plot(channels,dataPoints,...
        'Color',mFaceColor,...
        'LineWidth',lineWidth,...
        'DisplayName',sigObj.Name);

    case 'marker'

        plot(channels,dataPointsReal,'o',...
        'MarkerFaceColor',mFaceColor,...
        'MarkerEdgeColor',mFaceColor,...
        'DisplayName',sigObj.Name);
        if(any(dataPointsImag))
            plot(channels,dataPointsImag,'o',...
            'MarkerFaceColor',mFaceColor,...
            'MarkerEdgeColor',mFaceColor,...
            'DisplayName',sigObj.Name);
        end

    otherwise

        opts={'o','Color',mFaceColor};
        stem(channels,dataPointsReal,opts{:},...
        'LineWidth',lineWidth,...
        'DisplayName',sigObj.Name,...
        'Parent',hFig.CurrentAxes,...
        'ShowBaseLine',false);
        if(any(dataPointsImag))
            hold on;
            stem(channels,dataPointsImag,opts{:},...
            'LineWidth',lineWidth,...
            'DisplayName',sigObj.Name,...
            'ShowBaseLine',false);
            hold off;
        end
    end

    hFig.CurrentAxes.NextPlot='add';
end
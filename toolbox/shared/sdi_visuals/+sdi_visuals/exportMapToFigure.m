
function exportMapToFigure(hFig,~,rowIdx,colIdx,appInfo)
    sdiEngine=Simulink.sdi.Instance.engine;


    subplotID=8*(colIdx-1)+rowIdx;
    appInstanceID=getAppInstanceId(appInfo);
    boundSignals=sdi_visuals.getBoundSignalIDs(appInstanceID,subplotID);


    plotOnSubplot(sdiEngine,hFig,subplotID,boundSignals,appInfo);


    if numel(boundSignals)==4
        hLegend=legend(hFig.CurrentAxes,'show');
        hLegend.Interpreter='none';
        hLegend.Visible='on';
        hLegend.Location='northoutside';
    end
end


function plotOnSubplot(sdiEngine,~,subplotID,boundSignals,appInfo)


    if(numel(boundSignals)==4)
        paramName=boundSignals{1,1};


        if strcmpi(paramName,'Latitude')
            LatitudeSigID=boundSignals{2,1};
            LongitudeSigID=boundSignals{2,2};
        else
            LatitudeSigID=boundSignals{2,2};
            LongitudeSigID=boundSignals{2,1};
        end
        if sdiEngine.sigRepository.getSignalIsActivelyStreaming(LatitudeSigID)||...
            sdiEngine.sigRepository.getSignalIsActivelyStreaming(LongitudeSigID)
            error(message('SDI:sdi:SendToFigWhileStreaming'));
        end
        tsLat=exportSignalToTimeSeries(sdiEngine,LatitudeSigID,true,'AddEndTime',true);
        tsLong=exportSignalToTimeSeries(sdiEngine,LongitudeSigID,true,'AddEndTime',true);

        minLen=min(length(tsLat.Data),length(tsLong.Data));
        latData=tsLat.Data(1:minLen);
        longData=tsLong.Data(1:minLen);
        timeData=tsLat.Time(1:minLen);
        latSignalName=tsLat.Name;
        longSignalName=tsLong.Name;
        [leftCursorTime,rightCursorTime]=Simulink.sdi.getCursorPositions();
        geoplot(latData,longData,'Color',[0.2,0.6,1],'LineWidth',3,'DisplayName',['(',latSignalName,', ',longSignalName,')']);
        hold on



        plotMarkerOnSubplot(timeData(1),timeData,latData,longData);
        plotMarkerOnSubplot(timeData(minLen),timeData,latData,longData);
        if~isnan(leftCursorTime)
            plotMarkerOnSubplot(leftCursorTime,timeData,latData,longData);
        end
        if~isnan(rightCursorTime)
            plotMarkerOnSubplot(rightCursorTime,timeData,latData,longData);
        end
        hold off
    else

        geoplot([],[])
    end


    geobasemap streets
    appInstanceID=getAppInstanceId(appInfo);
    prefs=sdi_visuals.getVisualizationPreferences(appInstanceID,subplotID);
    if isfield(prefs,'layer')
        mapLayer=prefs.layer;
    end
    if~isempty(appInfo)&&~isempty(appInfo.recordBlk)
        pref=get_param(appInfo.recordBlk,'PlotPreferences');
        if isfield(pref,'Map')&&isfield(pref.Map,'Type')
            mapLayer=pref.Map.Type;
        end
    end
    if strcmpi(mapLayer,'Satellite')
        geobasemap satellite
    end


    if isfield(prefs,'boundingBox')
        bBox=prefs.boundingBox;
        if isfield(bBox,'_ne')&&isfield(bBox,'_sw')
            latLim(1)=bBox.('_ne').lat;
            latLim(2)=bBox.('_sw').lat;
            longLim(1)=bBox.('_ne').lng;
            longLim(2)=bBox.('_sw').lng;
            geolimits([min(latLim),max(latLim)],[min(longLim),max(longLim)])
        end
    end


    gx=gca;
    gx.LatitudeLabel.String='';
    gx.LongitudeLabel.String='';
    gx.TickLength=[0.0,0.0];
    gx.Grid='off';
    gx.LatitudeAxis.Visible='off';
    gx.LongitudeAxis.Visible='off';
    gx.Scalebar.Visible='off';
end

function plotMarkerOnSubplot(time,timeData,latData,longData)
    coordIdx=getCursorCoordinateIdxAtTime(time,timeData);
    marker=geoscatter(latData(coordIdx),longData(coordIdx),'^','filled','MarkerFaceColor',[0.9,0.4,0.2],'HandleVisibility','off');
    marker.DataTipTemplate.DataTipRows(:)=[dataTipTextRow('Time',time),...
    dataTipTextRow('Latitude',latData(coordIdx)),dataTipTextRow('Longitude',longData(coordIdx))];
end

function coordIdx=getCursorCoordinateIdxAtTime(curTime,timeValues)
    coordIdx=0;
    timeLength=length(timeValues);
    startTime=timeValues(1);
    endTime=timeValues(timeLength);


    lCoordIdx=ceil(0.1*(timeLength-1))+1;
    rCoordIdx=floor(0.9*(timeLength-1))+1;
    if timeLength==1||curTime<startTime
        coordIdx=0;
    elseif curTime>endTime
        coordIdx=timeLength;
    elseif abs(curTime-timeValues(lCoordIdx))<=eps()*abs(curTime)
        coordIdx=lCoordIdx;
    elseif abs(curTime-timeValues(rCoordIdx))<=eps()*abs(curTime)
        coordIdx=rCoordIdx;
    else
        coordIdx=floor(((curTime-startTime)/(endTime-startTime))*(timeLength-1))+1;
    end
end

function appInstanceID=getAppInstanceId(appInfo)
    appInstanceID=0;
    if~isempty(appInfo)&&~isempty(appInfo.recordBlk)
        appInstanceID=get_param(appInfo.recordBlk,'AppInstanceID');
    end
end

function exportTimePlotToFigure(this,clientId,axisId,hFig,prefStruct)
    [curPlot,isComparison]=findPlot(this,clientId,axisId);
    triggerMarkersDrawn=false;
    if isempty(curPlot)
        return
    end

    try
        if~isempty(curPlot.DatabaseIDs)
            hFig.CurrentAxes.UserData='drawn';
        end
        unsupportedIDs=[];
        numComplexSigs=0;

        for idx=1:length(curPlot.DatabaseIDs)
            if~this.isValidSignalID(curPlot.DatabaseIDs(idx))

                curPlot.DatabaseIDs(idx)=[];
                continue;
            end
            if this.sigRepository.getSignalIsActivelyStreaming(curPlot.DatabaseIDs(idx))
                error(message('SDI:sdi:SendToFigWhileStreaming'));
            end

            if strcmp(getSignalSourceType(this,curPlot.DatabaseIDs(idx)),'pass')

                continue;
            end


            if(strcmp(getSignalSourceType(this,curPlot.DatabaseIDs(idx)),'tolLower')&&...
                (axisId==2))

                continue;
            end

            ts=exportSignalToTimeSeries(this,curPlot.DatabaseIDs(idx),true,'AddEndTime',true);
            isEnum=isenum(ts.Data);
            isString=isstring(ts.Data);
            bEventBased=getSignalIsEventBased(this.sigRepository,curPlot.DatabaseIDs(idx));
            if isempty(ts.Time)


                clr=getSignalLineColor(this,curPlot.DatabaseIDs(idx));
                displayName=strcat(ts.Name,getString(message('SDI:sdi:NotSupportedSignal')));
                options={'Color',clr,'DisplayName',displayName};
                plot(NaN,options{:});
                continue
            end

            if curPlot.Normalized
                ts.Data=double(ts.Data);
                minVal=min(ts.Data);
                rangeVal=max(ts.Data)-minVal;
                if~rangeVal
                    ts.Data=ones(size(ts.Data));
                else
                    ts.Data=(ts.Data-minVal)/rangeVal;
                end
            end
            clr=getSignalLineColor(this,curPlot.DatabaseIDs(idx));
            ls=getSignalLineDashed(this,curPlot.DatabaseIDs(idx));
            lw=getSignalLineWidth(this,curPlot.DatabaseIDs(idx));
            opts={'Color',clr,'LineStyle',ls,'LineWidth',lw,'DisplayName',ts.Name};
            if length(ts.Time)<2
                opts=[{'o','MarkerFaceColor',clr},opts];%#ok<AGROW>
            elseif prefStruct.Markers
                opts=[{'o'},opts];%#ok<AGROW>
            end
            if bEventBased
                stem(ts.Time,ts.Data,opts{:},'Parent',hFig.CurrentAxes);
            else
                if isString||isEnum



                    plot(NaN,opts{:});
                    unsupportedIDs(end+1)=idx+numComplexSigs;%#ok
                else

                    isComplex=~isreal(ts.Data);
                    if isComplex
                        plot(ts.Time,real(ts.Data(:)),opts{:});
                        hold on;
                        plot(ts.Time,imag(ts.Data(:)),opts{:});
                        hold off;


                        numComplexSigs=numComplexSigs+1;
                    else
                        plot(ts,opts{:});
                    end
                end
            end


            try
                tmMode=getSignalTmMode(this,curPlot.DatabaseIDs(idx));
            catch
                tmMode='';
            end

            if~any(strcmp({'','none'},tmMode))
                if strcmp(tmMode,'samples')
                    xLabel=getString(message('SDI:sdi:Samples'));
                else
                    xLabel=getString(message('SDI:sdi:TimeSeconds'));
                end
            elseif idx==1
                xLabel=hFig.CurrentAxes.XLabel.String;
            end
            if isempty(hFig.CurrentAxes.XLabel.String)

                hFig.CurrentAxes.XLabel.String=xLabel;
            end
            hFig.CurrentAxes.NextPlot='add';
        end
    catch me
        delete(hFig);
        rethrow(me);
    end


    if curPlot.TimeSpan(1)==curPlot.TimeSpan(2)
        hFig.CurrentAxes.XLim=[curPlot.TimeSpan(1),curPlot.TimeSpan(1)+1];
    else
        hFig.CurrentAxes.XLim=curPlot.TimeSpan;
    end
    hFig.CurrentAxes.YLim=curPlot.YRange;
    sdiClient=Simulink.sdi.WebClient.getAllClients('sdi');


    if isempty(sdiClient)||isequal(sdiClient.ClientID,clientId)
        triggerMarkersDrawn=drawTriggerMarkers(hFig);
    end
    if~isempty(curPlot.DatabaseIDs)
        hLegend=legend(hFig.CurrentAxes,'show');
        if~isempty(unsupportedIDs)


            msgStr=getString(message('SDI:sdi:DataMustBeNumeric'));
            for usIdx=1:length(unsupportedIDs)
                currIdx=unsupportedIDs(usIdx);
                hLegend.String{currIdx}=[hLegend.String{currIdx},msgStr];
            end
        end
        hLegend.Interpreter='none';
        hLegend.Visible='on';
        if isComparison
            legendPos=prefStruct.legendPref.legendPositionComparisonView;
        else
            legendPos=prefStruct.legendPref.legendPositionRunsView;
        end
        switch legendPos
        case 'top'
            hLegend.Location='northoutside';
        case 'insideTop'
            hLegend.Location='northwest';
        case 'insideRight'
            hLegend.Location='northeast';
        case 'right'
            hLegend.Location='northeastoutside';
        otherwise
            hLegend.Visible='off';
        end
    end



    if strcmpi(prefStruct.ticksPosition,...
        getString(message('SDI:dialogs:None')))
        hFig.CurrentAxes.XTick=[];
        hFig.CurrentAxes.YTick=[];
    elseif strcmpi(prefStruct.ticksPosition,...
        getString(message('SDI:dialogs:TicksOptionOutside')))
        hFig.CurrentAxes.TickDir='out';
    end


    hFig.CurrentAxes.XTickLabelMode='auto';
    hFig.CurrentAxes.YTickLabelMode='auto';
    if strcmpi(prefStruct.tickLabelsDisplayed,...
        getString(message('SDI:dialogs:None')))
        hFig.CurrentAxes.XTickLabel={};
        hFig.CurrentAxes.YTickLabel={};
    elseif strcmpi(prefStruct.tickLabelsDisplayed,...
        [getString(message('SDI:dialogs:TLabel')),'-',getString(message('SDI:dialogs:AxisLabel'))])
        hFig.CurrentAxes.YTickLabel={};
    elseif strcmp(prefStruct.tickLabelsDisplayed,...
        [getString(message('SDI:dialogs:YLabel')),'-',getString(message('SDI:dialogs:AxisLabel'))])
        hFig.CurrentAxes.XTickLabel={};
    end




    hFig.CurrentAxes.XGrid='on';
    hFig.CurrentAxes.YGrid='on';

    if strcmpi(prefStruct.GridDisplay,...
        getString(message('SDI:dialogs:OffLabel')))
        hFig.CurrentAxes.XGrid='off';
        hFig.CurrentAxes.YGrid='off';
    elseif strcmpi(prefStruct.GridDisplay,...
        getString(message('SDI:dialogs:HorizontalLabel')))
        hFig.CurrentAxes.XGrid='off';
    elseif strcmpi(prefStruct.GridDisplay,...
        getString(message('SDI:dialogs:VerticalLabel')))
        hFig.CurrentAxes.YGrid='off';
    end

    hFig.CurrentAxes.Box='on';

    hFig.CurrentAxes.Title.String='';
    hFig.CurrentAxes.YLabel.String='';

    if(triggerMarkersDrawn)
        s=hLegend.String;
        allString=cell2mat(s);
        lenString=length(allString)+4;
        s=strrep(s,'data',[allString,'_data']);
        s(strncmpi(s,[allString,'_data'],lenString))=[];
        hLegend.String=s;
    end
end


function isDrawn=drawTriggerMarkers(hFig)
    isDrawn=false;
    [sigID,trig]=Simulink.sdi.getTriggerImpl('sdi');
    if(sigID>0)

        tColVect=[.09,.82,.09];

        tEdgeCol="none";
        heightY=hFig.CurrentAxes.YLim(2);

        x1_eventMarker=(trig.Position*(hFig.CurrentAxes.XLim(2)-hFig.CurrentAxes.XLim(1)))...
        +hFig.CurrentAxes.XLim(1);

        wx_eventMarker=(hFig.CurrentAxes.XLim(2)-hFig.CurrentAxes.XLim(1))*0.04;
        hy_eventMarker=(hFig.CurrentAxes.YLim(2)-hFig.CurrentAxes.YLim(1))*0.06;


        patch([x1_eventMarker-(wx_eventMarker/2),x1_eventMarker,x1_eventMarker+(wx_eventMarker/2),...
        x1_eventMarker-(wx_eventMarker/2)],...
        [heightY,heightY-hy_eventMarker,heightY,heightY],...
        tColVect,'EdgeColor',tEdgeCol);


        hx_levelMarker=(hFig.CurrentAxes.YLim(2)-hFig.CurrentAxes.YLim(1))*0.06;
        wy_levelMarker=(hFig.CurrentAxes.XLim(2)-hFig.CurrentAxes.XLim(1))*0.04;

        trigType=lower(trig.Type);
        if(strcmp(trigType,'edge')||strcmp(trigType,'timeout'))


            patch([hFig.CurrentAxes.XLim(2)-wy_levelMarker,hFig.CurrentAxes.XLim(2),hFig.CurrentAxes.XLim(2)],...
            [trig.Level,trig.Level+(hx_levelMarker/2),trig.Level-(hx_levelMarker/2)],...
            tColVect,'EdgeColor',tEdgeCol);

        elseif(strcmp(trigType,'pulsewidth')||strcmp(trigType,'transition')||strcmp(trigType,'runt')||strcmp(trigType,'window'))


            patch([hFig.CurrentAxes.XLim(2)-wy_levelMarker,hFig.CurrentAxes.XLim(2),hFig.CurrentAxes.XLim(2)],...
            [trig.UpperLevel,trig.UpperLevel+(hx_levelMarker/2),trig.UpperLevel-(hx_levelMarker/2)],...
            tColVect,'EdgeColor',tEdgeCol);


            patch([hFig.CurrentAxes.XLim(2)-wy_levelMarker,hFig.CurrentAxes.XLim(2),hFig.CurrentAxes.XLim(2)],...
            [trig.LowerLevel,trig.LowerLevel+(hx_levelMarker/2),trig.LowerLevel-(hx_levelMarker/2)],...
            tColVect,'EdgeColor',tEdgeCol);
        end
        isDrawn=true;
    end
end


function[curPlot,isComparison]=findPlot(this,clientId,axisId)
    curPlot=[];
    isComparison=false;
    clients=Simulink.sdi.WebClient.getAllClients();
    for idx=1:length(clients)
        if isempty(clientId)||strcmp(clients(idx).ClientID,clientId)
            maxYRange=0;
            for idx2=1:length(clients(idx).Axes)
                if clients(idx).Axes(idx2).ParentAxisID==axisId
                    axesObj=clients(idx).Axes(idx2);
                    if axesObj.AxisID~=axesObj.ParentAxisID&&length(axesObj.DatabaseIDs)==4



                        sigID=axesObj.DatabaseIDs(1);
                        st=this.sigRepository.getSignalSourceType(sigID);
                        isPassFail=any(strcmp(st,{'diffTolLower','diffTolUpper','comparedToMinusBaseline','pass'}));
                        if isPassFail
                            isComparison=true;
                            continue
                        end
                    end
                    axesYRange=abs(axesObj.YRange(1)-axesObj.YRange(2));
                    if axesYRange>maxYRange



                        curPlot=axesObj;
                        maxYRange=axesYRange;
                    end
                end
            end
        end
    end
end
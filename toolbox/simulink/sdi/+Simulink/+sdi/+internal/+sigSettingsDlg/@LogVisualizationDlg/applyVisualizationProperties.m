function applyVisualizationProperties(this,dlg)



    instrumentSignalIfNeeded(this);
    if isempty(this.Context)||~this.Context{1}.portH
        return
    end


    locApplyPortLogSettings(dlg,this.Context{1}.portH);


    locApplyFrameSetting(this,dlg);


    if Simulink.sdi.enableSDIVideo>1
        locApplyVisualType(this,dlg);
    end


    val=locConvertStrToIntVector(dlg.getWidgetValue(this.SUBPLOT_TAG));
    if isempty(this.LineSettings)
        this.LineSettings=struct('Axes',val);
    elseif~isempty(this.LineSettings)
        this.LineSettings.Axes=val;
    end


    complexFormat=dlg.getWidgetValue(this.COMPLEX_FORMAT_TAG);
    locApplyComplexFormatSetting(dlg.getSource().SigInfo,complexFormat);


    if~isempty(this.LineSettings)
        locApplyCustomVisualizationSettings(dlg.getSource().SigInfo,this.LineSettings);
    end
end


function locApplyPortLogSettings(dlg,ph)

    bCustomName=dlg.getWidgetValue('chkCustomName');
    if bCustomName
        set(ph,'DataLoggingNameMode','Custom');
    else
        set(ph,'DataLoggingNameMode','SignalName');
    end
    customName=dlg.getWidgetValue('txtCustomName');
    set(ph,'DataLoggingName',customName);


    bDecimate=dlg.getWidgetValue('chkDecimate');
    if bDecimate
        set(ph,'DataLoggingDecimateData','on');
    else
        set(ph,'DataLoggingDecimateData','off');
    end
    decimation=dlg.getWidgetValue('txtDecimate');
    set(ph,'DataLoggingDecimation',decimation);


    bMaxPts=dlg.getWidgetValue('chkMaxPoints');
    if bMaxPts
        set(ph,'DataLoggingLimitDataPoints','on');
    else
        set(ph,'DataLoggingLimitDataPoints','off');
    end
    maxPts=dlg.getWidgetValue('txtMaxPoints');
    set(ph,'DataLoggingMaxPoints',maxPts);


    sampleTime=dlg.getWidgetValue('txtSampleTime');
    set(ph,'DataLoggingSampleTime',sampleTime);
end


function locApplyFrameSetting(this,dlg)
    [sig,index]=this.findInstrumentedSignal();
    if~isempty(sig)
        val=double(dlg.getWidgetValue(this.FRAME_MODE_TAG));
        if~isequal(val,sig.IsFrameBased_)
            sig.IsFrameBased_=val;
            this.setInstrumentedSignal(sig,index);
        end
    end
end


function locApplyVisualType(this,dlg)
    [sig,index]=this.findInstrumentedSignal();
    if~isempty(sig)
        val=locConvertVisualTypeIndexToStr(dlg.getWidgetValue(this.VISUAL_TYPE_TAG));
        if~strcmp(val,sig.VisualType_)
            sig.VisualType_=val;
            this.setInstrumentedSignal(sig,index);
        end
    end
end


function ret=locConvertStrToIntVector(str)
    ret=eval(sprintf('uint32([%s])',str));
end


function ret=locConvertVisualTypeIndexToStr(val)
    switch double(val)
    case 1
        ret='video';
    otherwise
        ret='';
    end
end


function locApplyComplexFormatSetting(sigInfo,complexFormat)

    mdl=sigInfo.mdl;
    clients=get_param(sigInfo.mdl,'StreamingClients');
    if isempty(clients)
        clients=Simulink.HMI.StreamingClients(sigInfo.mdl);
    end
    [client,clientIdx,bWasAdded]=Simulink.sdi.internal.Utils.getWebClient(sigInfo);


    curVal=0;
    if isfield(client.ObserverParams,'ComplexFormat')
        curVal=double(client.ObserverParams.ComplexFormat);
    end
    if curVal~=complexFormat
        client.ObserverParams.ComplexFormat=double(complexFormat);
        if bWasAdded
            clients.add(client);
        else
            clients.set(clientIdx,client);
        end
        set_param(mdl,'StreamingClients',clients);
    end
end


function locApplyCustomVisualizationSettings(sigInfo,lineSettings)

    if isfield(lineSettings,'Axes')
        axesVal=lineSettings.Axes;
        if~isempty(axesVal)
            lineSettings.Axes=reshape(axesVal,1,length(axesVal));
        end
        lineSettings.Axes=uint32(lineSettings.Axes);
    end


    if~isfield(lineSettings,'Color')&&isfield(lineSettings,'ColorString')&&~isempty(lineSettings.ColorString)
        lineSettings.Color=...
        Simulink.sdi.internal.LineSettings.hexStringToColor(lineSettings.ColorString);
    end


    if isfield(lineSettings,'LineStyle')&&isempty(lineSettings.LineStyle)
        lineSettings=rmfield(lineSettings,'LineStyle');
    end


    if isfield(lineSettings,'LineWidth')&&isempty(lineSettings.LineWidth)
        lineSettings=rmfield(lineSettings,'LineWidth');
    end


    mdl=sigInfo.mdl;
    clients=get_param(sigInfo.mdl,'StreamingClients');
    if isempty(clients)
        clients=Simulink.HMI.StreamingClients(sigInfo.mdl);
    end
    [client,clientIdx,wasAdded]=Simulink.sdi.internal.Utils.getWebClient(sigInfo);


    LSfields={'LineStyle','LineWidth','Color','ColorString','Axes'};
    bWasChange=false;
    for j=1:length(LSfields)
        if isfield(lineSettings,LSfields{j})
            if~locAreEquivalent(client.ObserverParams.LineSettings.(LSfields{j}),lineSettings.(LSfields{j}))
                client.ObserverParams.LineSettings.(LSfields{j})=lineSettings.(LSfields{j});
                bWasChange=true;
            end
        end
    end


    if bWasChange
        if wasAdded
            clients.add(client);
        else
            clients.set(clientIdx,client);
        end
        set_param(mdl,'StreamingClients',clients);
        simulink.hmi.signal.syncAllScopeColorsForSignal(client);
    end
end


function ret=locAreEquivalent(a,b)
    ret=...
    isequal(a,b)||...
    isempty(a)&&isempty(b);
end




function doBlockReplacement(modelName)

    [blockpaths,cachedProps,cachedTypes,cachedLibs]=Simulink.HMI.getReplacementEntries(modelName);
    if isempty(blockpaths)
        return
    end


    if strcmp(modelName,'simulink_hmi_blocks')
        return
    end





    persistent modelsInProgress
    if isempty(modelsInProgress)
        modelsInProgress=containers.Map;
    end
    if modelsInProgress.isKey(modelName)
        return
    end
    modelsInProgress(modelName)=true;


    tmp=onCleanup(@()set_param(modelName,'Dirty','off'));


    sw=warning('off','all');
    tmp2=onCleanup(@()warning(sw));


    isLockedLibrary=false;
    if utils.isLockedLibrary(modelName)
        isLockedLibrary=true;
        set_param(modelName,'Lock','off');
    end



    clients=get_param(modelName,'StreamingClients');
    set_param(modelName,'StreamingClients',[]);


    streamBlkSources=containers.Map;
    for index=1:length(blockpaths)
        streamBlkSources=locDoReplacement(...
        modelName,...
        blockpaths{index},...
        cachedProps{index},...
        cachedTypes{index},...
        cachedLibs(index),...
        streamBlkSources);
    end


    locUpdateObservers(modelName,streamBlkSources,clients);


    if isLockedLibrary
        delete(tmp);
        set_param(modelName,'Lock','on');
    end


    modelsInProgress.remove(modelName);
end


function streamBlkSources=locDoReplacement(model,blockPath,widgetId,widgetType,isLibWidget,streamBlkSources)

    persistent typeMap
    if isempty(typeMap)
        sourceWidgetTypes={...
        'lamp',...
        'multistateimage',...
        'sliderswitch',...
        'toggleswitch',...
        'rockerswitch',...
        'discreteknob',...
        'pushbutton',...
        'circulargauge',...
        'semicirculargauge',...
        'ninetydegreegauge',...
        'lineargauge',...
        'continuousknob',...
        'slider',...
'sdiscope'
        };
        destBlockTypes={...
        'LampBlock',...
        'MultiStateImageBlock',...
        'SliderSwitchBlock',...
        'ToggleSwitchBlock',...
        'RockerSwitchBlock',...
        'RotarySwitchBlock',...
        'PushButtonBlock',...
        'CircularGaugeBlock',...
        'SemiCircularGaugeBlock',...
        'QuarterGaugeBlock',...
        'LinearGaugeBlock',...
        'KnobBlock',...
        'SliderBlock',...
'DashboardScope'
        };
        typeMap=containers.Map(sourceWidgetTypes,destBlockTypes);
    end


    if~isKey(typeMap,widgetType)
        return
    end
    newBlockType=typeMap(widgetType);


    try
        get_param(blockPath,'Handle');
    catch me %#ok<NASGU>
        return
    end


    if~strcmp(get_param(blockPath,'BlockType'),'SubSystem')
        return
    end


    [webhmi,binding,cachedWidget,propNames]=...
    locGetWidgetProps(model,widgetId,isLibWidget,blockPath);


    newBlockPath=locReplaceBlock(blockPath,newBlockType);


    if~isempty(newBlockPath)&&~isempty(cachedWidget)
        webhmi.deleteBlock(widgetId,isLibWidget);
        locCopyCachedParamsToNewBlock(newBlockPath,cachedWidget,binding,propNames);
        if isa(binding,'Simulink.HMI.SignalSpecification')
            bpath=binding.BlockPath.getBlock(1);
            if isKey(streamBlkSources,bpath)
                ss=streamBlkSources(bpath);
                ss(end+1).bWasFound=false;
                ss(end).OutputPortIndex=binding.OutputPortIndex;
                streamBlkSources(bpath)=ss;
            else
                ss.bWasFound=false;
                ss.OutputPortIndex=binding.OutputPortIndex;
                streamBlkSources(bpath)=ss;
            end
        end
    end
end


function[webhmi,binding,cachedWidget,propsToCache]=locGetWidgetProps(model,widgetId,isLibWidget,blockPath)
    modelHandle=get_param(model,'Handle');
    webhmi=Simulink.HMI.WebHMI.getWebHMI(modelHandle);
    oldWidget=utils.getWidget(model,widgetId,isLibWidget);
    binding=utils.getBoundElement(model,widgetId,isLibWidget);
    cachedWidget=locGetCachedProps(oldWidget);
    if isempty(cachedWidget)
        propsToCache={};
        return
    end

    propsToCache={...
    'ShowInitialText',...
    'ShowName',...
    'FontName',...
    'FontSize',...
    'FontWeight',...
    'FontAngle',...
    'ForegroundColor',...
    'BackgroundColor',...
    'DropShadow',...
    'Commented'};

    for idx=1:length(propsToCache)
        propName=propsToCache{idx};
        cachedWidget.(propName)=get_param(blockPath,propName);
    end
end


function ret=locGetCachedProps(widget)
    if isa(widget,'Simulink.HMI.SDIScope')
        ret.YAxisLimits=widget.YAxisLimits;
        ret.TimeSpan=widget.TimeSpan;
        ret.FitToViewAtStop=widget.FitToViewAtStop;
        ret.LegendPosition=widget.LegendPosition;
        ret.Signals=widget.getBoundSignals();
    else
        ret=struct(widget);
    end
end


function blockPath=locReplaceBlock(blockPath,newBlockType)
    try
        hOldBlock=get_param(blockPath,'Handle');
        newBlockType=['built-in/',newBlockType];
        slInternal('replace_block',hOldBlock,newBlockType);
    catch me %#ok<NASGU>
        blockPath='';
        return
    end


    if strcmp(get_param(blockPath,'BlockType'),'SubSystem')
        blockPath='';
    end
end


function locCopyCachedParamsToNewBlock(blockPath,widget,binding,propNames)


    set_param(blockPath,'BulkUpdateMode','on');
    tmp=onCleanup(@()set_param(blockPath,'BulkUpdateMode','off'));


    if isfield(widget,'LablePosition')
        set_param(blockPath,'LabelPosition',widget.LabelPosition);
    end
    for idx=1:length(propNames)
        prop=propNames{idx};
        set_param(blockPath,prop,widget.(prop));
    end


    if~isempty(binding)
        set_param(blockPath,'BindingDuringReplace',binding);
    end


    type=get_param(blockPath,'BlockType');
    switch(type)
    case 'LampBlock'
        locCopyCachedParamsToLampBlock(blockPath,widget);
    case 'MultiStateImageBlock'
        locCopyCachedParamsToMultiStateImageBlock(blockPath,widget);
    case{'SliderSwitchBlock','ToggleSwitchBlock','RockerSwitchBlock'}
        locCopyCachedParamsToSwitchBlock(blockPath,widget);
    case 'RotarySwitchBlock'
        locCopyCachedParamsToRotarySwitchBlock(blockPath,widget);
    case 'PushButtonBlock'
        locCopyCachedParamsToPushButtonBlock(blockPath,widget);
    case{'CircularGaugeBlock','SemiCircularGaugeBlock','QuarterGaugeBlock','LinearGaugeBlock'}
        locCopyCachedParamsToGaugeBlock(blockPath,widget);
    case{'KnobBlock','SliderBlock'}
        locCopyCachedParamsToKnobBlock(blockPath,widget);
    case 'DashboardScope'
        locCopyCachedParamsToScope(blockPath,widget);
    end
end


function locCopyCachedParamsToLampBlock(blockPath,widget)
    if~isempty(widget)
        set_param(blockPath,'DefaultColor',widget.UndefinedStateColor);
        set_param(blockPath,'States',{widget.States,widget.StateColors});
        set_param(blockPath,'LabelPosition',widget.LabelPosition);
    end
end


function locCopyCachedParamsToMultiStateImageBlock(blockPath,widget)
    if~isempty(widget)
        undefImg.Size=uint64(widget.UndefinedStateImageSize);
        undefImg.Image=widget.UndefinedStateImage{1};
        undefImg.Thumbnail=widget.UndefinedStateImageThumb{1};
        set_param(blockPath,'DefaultImage',undefImg);

        states=struct.empty();
        numStates=length(widget.States);
        for idx=1:numStates
            states(idx).State=double(widget.States(idx));
            states(idx).Size=uint64(widget.StateImageSizes(idx,:));
            states(idx).Image=widget.StateImages{idx};
            states(idx).Thumbnail=widget.StateImageThumbs{idx};
        end
        set_param(blockPath,'States',states);

        set_param(blockPath,'LabelPosition',widget.LabelPosition);
        set_param(blockPath,'ScaleMode',widget.ScaleMode);
    end
end

function locCopyCachedParamsToSwitchBlock(blockPath,widget)
    if~isempty(widget)
        states=widget.States;
        stateLabels=widget.StateLabels;
        set_param(blockPath,'Values',{stateLabels,states});
        set_param(blockPath,'LabelPosition',widget.LabelPosition);




    end
end


function locCopyCachedParamsToRotarySwitchBlock(blockPath,widget)
    if~isempty(widget)

        vals{1}=widget.StateLabels;
        vals{2}=widget.States;
        set_param(blockPath,'Values',vals);


        set_param(blockPath,'LabelPosition',widget.LabelPosition);




    end
end


function locCopyCachedParamsToPushButtonBlock(blockPath,widget)
    if~isempty(widget)
        set_param(blockPath,'ButtonText',widget.Text);
        set_param(blockPath,'OnValue',num2str(widget.OnValue));
        set_param(blockPath,'LabelPosition',widget.LabelPosition);
    end
end


function locCopyCachedParamsToGaugeBlock(blockPath,widget)
    if~isempty(widget)
        set_param(blockPath,'ScaleMin',num2str(widget.ScaleLimits(1)));
        set_param(blockPath,'ScaleMax',num2str(widget.ScaleLimits(2)));

        if widget.AutoTickInterval
            set_param(blockPath,'TickInterval','auto');
        elseif length(widget.MajorTicks)>1
            tickInv=widget.MajorTicks(2)-widget.MajorTicks(1);
            set_param(blockPath,'TickInterval',num2str(tickInv));
        end

        numStates=size(widget.ScaleColorLimits,1);
        scaleColors=struct.empty();
        for idx=1:numStates
            scaleColors(idx).Min=widget.ScaleColorLimits(idx,1);
            scaleColors(idx).Max=widget.ScaleColorLimits(idx,2);
            scaleColors(idx).Color=(1/255).*widget.ScaleColors(idx,:);
        end
        set_param(blockPath,'ScaleColors',scaleColors);
    end
end


function locCopyCachedParamsToKnobBlock(blockPath,widget)
    if~isempty(widget)
        set_param(blockPath,'ScaleMin',num2str(widget.ScaleLimits(1)));
        set_param(blockPath,'ScaleMax',num2str(widget.ScaleLimits(2)));

        if widget.AutoTickInterval
            set_param(blockPath,'TickInterval','auto');
        elseif length(widget.MajorTicks)>1
            tickInv=widget.MajorTicks(2)-widget.MajorTicks(1);
            set_param(blockPath,'TickInterval',num2str(tickInv));
        end

        set_param(blockPath,'ScaleType',widget.ScaleType);
    end
end


function locCopyCachedParamsToScope(blockPath,widget)
    if~isempty(widget)
        set_param(blockPath,'Ymin',num2str(widget.YAxisLimits(1)));
        set_param(blockPath,'Ymax',num2str(widget.YAxisLimits(2)));
        if widget.TimeSpan>0
            set_param(blockPath,'TimeSpan',num2str(widget.TimeSpan));
        end
        set_param(blockPath,'UpdateMode','wrap');
        if~widget.FitToViewAtStop
            set_param(blockPath,'ScaleAtStop','off');
        end
        switch lower(widget.LegendPosition)
        case 'top'
            set_param(blockPath,'LegendPosition','Top');
        case 'right'
            set_param(blockPath,'LegendPosition','Right');
        case 'hide'
            set_param(blockPath,'LegendPosition','Hide');
        end

        if~isempty(widget.Signals)
            mdl=bdroot(blockPath);
            bindings=cell(size(widget.Signals));
            for idx=1:length(widget.Signals)
                bindings{idx}=Simulink.HMI.SignalSpecification;
                bindings{idx}.BlockPath=[mdl,'/',widget.Signals(idx).BlockPath];
                bindings{idx}.OutputPortIndex=widget.Signals(idx).OutputPortIndex;
            end
            set_param(blockPath,'Binding',bindings);
        end
    end
end


function locUpdateObservers(modelName,streamBlkSources,clients)
    if isempty(clients)
        clients=Simulink.HMI.StreamingClients(modelName);
    end


    numClients=clients.Count;
    for idx=1:numClients
        c=get(clients,idx);
        sinfo=c.SignalInfo;
        if~isempty(sinfo)
            bpath=sinfo.BlockPath.getBlock(1);
            if strcmpi(c.ObserverType,'hmi_web_widget_observer')&&isKey(streamBlkSources,bpath)
                ss=streamBlkSources(bpath);
                bUpdatedClient=false;
                for idx2=1:length(ss)
                    if ss(idx2).OutputPortIndex==sinfo.OutputPortIndex
                        if~bUpdatedClient
                            c.ObserverType='dashboardblocks_observer';
                            set(clients,idx,c);
                            bUpdatedClient=true;
                        end
                        ss(idx2).bWasFound=true;
                        streamBlkSources(bpath)=ss;
                    end
                end
            end
        end
    end


    bpaths=keys(streamBlkSources);
    for idx=1:length(bpaths)
        bpath=bpaths{idx};
        ss=streamBlkSources(bpath);
        for idx2=1:length(ss)
            if~ss(idx2).bWasFound
                locAddClient(bpath,ss(idx2).OutputPortIndex,clients);
            end
        end
    end

    set_param(modelName,'StreamingClients',clients);
end


function locAddClient(bpath,outputPortIndex,clients)

    sigInfo=Simulink.HMI.SignalSpecification;
    sigInfo.BlockPath=bpath;
    sigInfo.OutputPortIndex=outputPortIndex;
    try
        sigInfo.CachedBlockHandle_=get_param(bpath,'Handle');
    catch

        return;
    end


    sigInfo=Simulink.sdi.internal.ObserverInterface.instrumentModel(sigInfo,false,false);


    client=Simulink.HMI.SignalClient;
    client.SignalInfo=sigInfo;
    client.ObserverType_='dashboardblocks_observer';
    add(clients,client);
end

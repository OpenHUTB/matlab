




function doAeroHMIBlockReplacement(modelName)

    [blockpaths,cachedProps,cachedTypes,cachedLibs]=Simulink.HMI.getReplacementEntries(modelName);
    if isempty(blockpaths)
        return
    end


    if strcmp(modelName,'aerolibhmi')
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


    if isempty(streamBlkSources)
        set_param(modelName,'StreamingClients',clients);
    else
        locUpdateObservers(modelName,streamBlkSources,clients);
    end


    if isLockedLibrary
        delete(tmp);
        set_param(modelName,'Lock','on');
    end


    modelsInProgress.remove(modelName);
end


function streamBlkSources=locDoReplacement(model,blockPath,widgetId,widgetType,isLibWidget,streamBlkSources)

    persistent typeAeroMap
    if isempty(typeAeroMap)
        sourceAeroWidgetTypes={...
        'airspeedindicator',...
        'altimeter',...
        'artificialhorizon',...
        'climbindicator',...
        'egtindicator',...
        'headingindicator',...
        'rpmindicator',...
'turncoordinator'
        };
        destAeroBlockTypes={...
        'AirspeedIndicatorBlock',...
        'AltimeterBlock',...
        'ArtificialHorizonBlock',...
        'ClimbIndicatorBlock',...
        'EGTIndicatorBlock',...
        'HeadingIndicatorBlock',...
        'RPMIndicatorBlock',...
'TurnCoordinatorBlock'
        };
        typeAeroMap=containers.Map(sourceAeroWidgetTypes,destAeroBlockTypes);
    end

    if~isKey(typeAeroMap,widgetType)
        return;
    else
        newBlockType=typeAeroMap(widgetType);
    end


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
                ss(end).ObserverType=locGetObserverType(blockPath);
                streamBlkSources(bpath)=ss;
            else
                ss.bWasFound=false;
                ss.OutputPortIndex=binding.OutputPortIndex;
                ss.ObserverType=locGetObserverType(blockPath);
                streamBlkSources(bpath)=ss;
            end
        end
    end
end


function ObserverType=locGetObserverType(blockPath)

    type=get_param(blockPath,'BlockType');
    switch(type)
    case{'ArtificialHorizonBlock','TurnCoordinatorBlock'}
        ObserverType='aerohmiblocks_observer';
    otherwise
        ObserverType='dashboardblocks_observer';
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
    ret=struct(widget);
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


    if isfield(widget,'LabelPosition')
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
    case{'AirspeedIndicatorBlock','EGTIndicatorBlock'}
        locCopyCachedParamsToAeroSimpleColorBlock(blockPath,widget);
    case{'RPMIndicatorBlock'}
        locCopyCachedParamsToAeroRPMBlock(blockPath,widget);
    case{'ClimbIndicatorBlock'}
        locCopyCachedParamsToAeroClimblock(blockPath,widget);
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
                            c.ObserverType=ss(idx2).ObserverType;
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

function locCopyCachedParamsToAeroSimpleColorBlock(blockPath,widget)
    if~isempty(widget)
        set_param(blockPath,'ScaleMin',num2str(widget.ScaleLimits(1)));
        set_param(blockPath,'ScaleMax',num2str(widget.ScaleLimits(2)));
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

function locCopyCachedParamsToAeroRPMBlock(blockPath,widget)
    if~isempty(widget)
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
function locCopyCachedParamsToAeroClimblock(blockPath,widget)
    if~isempty(widget)
        set_param(blockPath,'ScaleMax',num2str(widget.ScaleLimits(2)));
    end
end

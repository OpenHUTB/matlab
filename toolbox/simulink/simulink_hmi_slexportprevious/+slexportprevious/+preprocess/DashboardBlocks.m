function DashboardBlocks(obj)






    if obj.ver.isReleaseOrEarlier('R2019b')
        locRemoveBlockOfType(obj,'CustomWebBlock');
    end


    if obj.ver.isReleaseOrEarlier('R2019a')
        Simulink.HMI.addInstrumentationForRuntimeBindings(get_param(obj.modelName,'Handle'));
    end


    if obj.ver.isReleaseOrEarlier('R2019a')



        blks=find_system(obj.modelName,'regexp','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'WebBlockId','wbid');

        obj.appendRules(locRestoreOldStyleWebBlockId(blks));
    end


    if obj.ver.isReleaseOrEarlier('R2018a')
        locReplaceBlockOfType(obj,'PushButtonBlock');
        locReplaceBlockOfType(obj,'CircularGaugeBlock');
        locReplaceBlockOfType(obj,'SemiCircularGaugeBlock');
        locReplaceBlockOfType(obj,'QuarterGaugeBlock');
        locReplaceBlockOfType(obj,'LinearGaugeBlock');
        locReplaceBlockOfType(obj,'KnobBlock');
        locReplaceBlockOfType(obj,'SliderBlock');
        locReplaceBlockOfType(obj,'DashboardScope');

        locRemoveBlockOfType(obj,'CustomGaugeBlock');
    end


    if isR2017bOrEarlier(obj.ver)
        locReplaceBlockOfType(obj,'LampBlock');
        locReplaceBlockOfType(obj,'RotarySwitchBlock');
        locReplaceBlockOfType(obj,'MultiStateImageBlock');
        locReplaceBlockOfType(obj,'SliderSwitchBlock');
        locReplaceBlockOfType(obj,'ToggleSwitchBlock');
        locReplaceBlockOfType(obj,'RockerSwitchBlock');


        obj.appendRule('<Object<ClassName|"Simulink.dialog.Container"><AlignPrompts:remove>>');
    end


    if isR2017aOrEarlier(obj.ver)
        locRemoveBlockOfType(obj,'RadioButtonGroup');
        locRemoveBlockOfType(obj,'ComboBox');
        locRemoveBlockOfType(obj,'Checkbox');
        locRemoveBlockOfType(obj,'DisplayBlock');
        locRemoveBlockOfType(obj,'EditField');
        locRemoveBlockOfType(obj,'CallbackButton');
    end


    if isR2016aOrEarlier(obj.ver)
        locRemoveBlockOfWebBlockType(obj,'multistateimage');
    end


    if isR2015aOrEarlier(obj.ver)
        locRemoveBlockOfWebBlockType(obj,'pushbutton');
        locRemoveBlockOfWebBlockType(obj,'slider');

        if Simulink.internal.useFindSystemVariantsMatchFilter('DEFAULT_ALLVARIANTS')


            blks=find_system(obj.modelName,'LookUnderMasks','all',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'IncludeCommented','on','IsWebBlock','on');
        else
            blks=find_system(obj.modelName,'LookUnderMasks','all',...
            'MatchFilter',@Simulink.match.allVariants,'IncludeCommented','on','IsWebBlock','on');
        end
        locRenameMaskType(blks,obj);
    end


    if isR2014bOrEarlier(obj.ver)


        if Simulink.internal.useFindSystemVariantsMatchFilter('DEFAULT_ALLVARIANTS')


            blks=find_system(obj.modelName,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'LookUnderMasks','all',...
            'IncludeCommented','on',...
            'IsWebBlock','on');
        else
            blks=find_system(obj.modelName,...
            'LookUnderMasks','all',...
            'MatchFilter',@Simulink.match.allVariants,...
            'IncludeCommented','on',...
            'IsWebBlock','on');
        end


        locRemoveBlocks(blks,obj);
    end







    if obj.ver.isReleaseOrEarlier('R2018a')
        locReplaceStreamingClients(obj);
    end
    locRemoveInvalidAndDupStreamingClients(obj);
end


function locRemoveBlockOfType(obj,blockType)

    if Simulink.internal.useFindSystemVariantsMatchFilter('DEFAULT_ALLVARIANTS')


        blks=find_system(obj.modelName,...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'LookUnderMasks','all',...
        'IncludeCommented','on',...
        'BlockType',blockType);
    else
        blks=find_system(obj.modelName,...
        'LookUnderMasks','all',...
        'MatchFilter',@Simulink.match.allVariants,...
        'IncludeCommented','on',...
        'BlockType',blockType);
    end
    locRemoveBlocks(blks,obj);
end


function locRemoveBlockOfWebBlockType(obj,webBlockType)

    if Simulink.internal.useFindSystemVariantsMatchFilter('DEFAULT_ALLVARIANTS')


        blks=find_system(obj.modelName,...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'LookUnderMasks','all',...
        'IncludeCommented','on',...
        'WebBlockType',webBlockType);
    else
        blks=find_system(obj.modelName,...
        'LookUnderMasks','all',...
        'MatchFilter',@Simulink.match.allVariants,...
        'IncludeCommented','on',...
        'WebBlockType',webBlockType);
    end
    locRemoveBlocks(blks,obj);
end


function locRemoveBlocks(blks,obj)


    if~isempty(blks)


        tempModel=getTempMdl(obj);
        replacementBlock=createEmptySubsystem(obj,tempModel,'Dashboard Widget',0,0);
        delblk=onCleanup(@()delete_block(replacementBlock));


        for idx=1:length(blks)
            pos=get_param(blks{idx},'Position');
            name=get_param(blks{idx},'Name');

            delete_block(blks{idx});
            add_block(replacementBlock,blks{idx});
            set_param(blks{idx},'Position',pos);
            set_param(blks{idx},'Name',name);
        end
    end
end



function locRenameMaskType(blks,~)

    newMaskType='MathWorksWebBlock';
    if~isempty(blks)
        for idx=1:length(blks)
            set_param(blks{idx},'MaskType',newMaskType);
        end
    end
end


function locReplaceBlockOfType(obj,blockType)


    blks=find_system(...
    obj.modelName,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'BlockType',blockType);
    if~isempty(blks)

        legacyType=locGetOldBlockType(blockType);
        for idx=1:length(blks)


            handle=get_param(blks{idx},'Handle');


            cachedCoreBlockParameters=locCacheCoreBlockParameters(blks{idx});


            replace_block(obj.modelName,'Handle',handle,...
            'built-in/SubSystem','noprompt');


            locPrepareLegacyBlock(obj,blks{idx},legacyType,cachedCoreBlockParameters);
        end
    end
end


function oldBlockType=locGetOldBlockType(blockType)
    switch blockType
    case 'LampBlock'
        oldBlockType='Lamp';
    case 'SliderSwitchBlock'
        oldBlockType='SliderSwitch';
    case 'ToggleSwitchBlock'
        oldBlockType='ToggleSwitch';
    case 'RockerSwitchBlock'
        oldBlockType='RockerSwitch';
    case 'MultiStateImageBlock'
        oldBlockType='MultiStateImage';
    case 'RotarySwitchBlock'
        oldBlockType='DiscreteKnob';
    case 'PushButtonBlock'
        oldBlockType='PushButton';
    case 'DashboardScope'
        oldBlockType='SDIScope';
    case 'CircularGaugeBlock'
        oldBlockType='CircularGauge';
    case 'SemiCircularGaugeBlock'
        oldBlockType='SemiCircularGauge';
    case 'QuarterGaugeBlock'
        oldBlockType='NinetyDegreeGauge';
    case 'LinearGaugeBlock'
        oldBlockType='LinearGauge';
    case 'KnobBlock'
        oldBlockType='ContinuousKnob';
    case 'SliderBlock'
        oldBlockType='Slider';
    otherwise
    end
end


function cache=locCacheCoreBlockParameters(coreBlock)
    cache=struct();

    blockType=get_param(coreBlock,'BlockType');
    location=get_param(coreBlock,'Position');
    binding=get_param(coreBlock,'Binding');

    cache.labelPosition=get_param(coreBlock,'LabelPosition');
    cache.width=location(3)-location(1);
    cache.height=location(4)-location(2);
    cache.location={location(1),location(2)};
    cache.binding=binding;
    cache.blockPath=coreBlock;
    cache.position=location;
    cache.referenceBlock=get_param(coreBlock,'ReferenceBlock');

    switch blockType
    case 'LampBlock'
        cache.states=get_param(coreBlock,'States');
        cache.defaultColor=get_param(coreBlock,'DefaultColor');
    case 'RotarySwitchBlock'
        cache.values=get_param(coreBlock,'Values');
    case 'MultiStateImageBlock'
        cache.states=get_param(coreBlock,'States');
        cache.defaultImage=get_param(coreBlock,'DefaultImage');
        cache.scaleMode=get_param(coreBlock,'ScaleMode');
    case{'SliderSwitchBlock','ToggleSwitchBlock','RockerSwitchBlock'}
        cache.states=get_param(coreBlock,'Values');
    case 'PushButtonBlock'
        cache.text=get_param(coreBlock,'ButtonText');
        cache.onValue=str2double(get_param(coreBlock,'OnValue'));
    case{'CircularGaugeBlock','SemiCircularGaugeBlock','QuarterGaugeBlock','LinearGaugeBlock'}
        cache.ScaleMin=str2double(get_param(coreBlock,'ScaleMin'));
        cache.ScaleMax=str2double(get_param(coreBlock,'ScaleMax'));
        cache.TickInterval=get_param(coreBlock,'TickInterval');
        cache.ScaleColors=get_param(coreBlock,'ScaleColors');
    case{'KnobBlock','SliderBlock'}
        cache.ScaleMin=str2double(get_param(coreBlock,'ScaleMin'));
        cache.ScaleMax=str2double(get_param(coreBlock,'ScaleMax'));
        cache.TickInterval=get_param(coreBlock,'TickInterval');
        cache.ScaleType=simulink.hmi.getScaleType(...
        get_param(coreBlock,'ScaleType'));
    case 'DashboardScope'
        cache.Ymin=str2double(get_param(coreBlock,'Ymin'));
        cache.Ymax=str2double(get_param(coreBlock,'Ymax'));
        cache.TimeSpan=get_param(coreBlock,'TimeSpan');
        if strcmpi(cache.TimeSpan,'auto')
            cache.TimeSpan=-1;
        else
            cache.TimeSpan=str2double(cache.TimeSpan);
        end
        cache.FitToViewAtStop=strcmpi(get_param(coreBlock,'ScaleAtStop'),'on');
        cache.LegendPosition=lower(get_param(coreBlock,'LegendPosition'));
        cache.modelName=bdroot(coreBlock);

    otherwise
    end
end


function locPrepareLegacyBlock(obj,blk,legacyType,cachedProperties)
    modelHandle=get_param(obj.modelName,'Handle');


    id=sdi.Repository.generateUUID();


    p=Simulink.Mask.get(blk);
    if isempty(p)
        p=Simulink.Mask.create(blk);
    end


    set_param(blk,'Position',cachedProperties.position);


    set_param(blk,'DialogControllerArgs',{legacyType});
    set_param(blk,'DialogController','hmiCreateDDGDialog');
    set_param(blk,'MaskType','MWDashboardBlock');
    set_param(blk,'MaskDescription',locGetLegacyblockDesc(legacyType));
    set_param(blk,'MaskDisplay',locGetLegacyblockIcon(legacyType));
    set_param(blk,'MaskHelp',locGetLegacyblockHelp(legacyType));
    set_param(blk,'MaskIconFrame','off');
    set_param(blk,'ShowName','off');


    p.addParameter('Type','edit','Name','webBlockId',...
    'Prompt','WebBlock Id','Value',id,...
    'Evaluate','off','Tunable','off',...
    'ReadOnly','off','Hidden','on','NeverSave','off');

    p.addParameter('Type','edit','Name','webBlockType',...
    'Prompt','WebBlock Type','Value',lower(legacyType),...
    'Evaluate','off','Tunable','off','ReadOnly','on',...
    'Hidden','on','NeverSave','off');

    p.addParameter('Type','checkbox','Name','ShowInLibBrowser','Value','on',...
    'Evaluate','off','Tunable','off','ReadOnly','on','Hidden','on',...
    'NeverSave','off');

    p.addParameter('Type','checkbox','Name','ShowInitialText','Value','on',...
    'Evaluate','off','Tunable','off','ReadOnly','off','Hidden','on',...
    'NeverSave','off');

    p.addParameter('Type','edit','Name','HMISrcModelName','Prompt',...
    'Source Model','Value',obj.modelName,'Evaluate','off',...
    'Tunable','off','ReadOnly','off','Hidden','on','NeverSave','on');



    set_param(blk,'isWebBlock','on');


    set_param(blk,'ReferenceBlock',cachedProperties.referenceBlock);


    if isempty(cachedProperties.referenceBlock)


        webhmi=Simulink.HMI.WebHMI.getWebHMI(modelHandle);
        if isempty(webhmi)
            webhmi=Simulink.HMI.WebHMI.createNewWebHMI(modelHandle,obj.modelName);
        end
        serializedLegacyBlock=locCreateSerializedBlock(obj,id,legacyType,...
        cachedProperties);
        webhmi.deserialize(serializedLegacyBlock);
    end
end


function desc=locGetLegacyblockDesc(type)
    switch type
    case 'Lamp'
        desc=DAStudio.message('SimulinkHMI:dialogs:LampDialogDesc');
    case 'DiscreteKnob'
        desc=DAStudio.message('SimulinkHMI:dialogs:DiscreteKnobDialogDesc');
    case 'MultiStateImage'
        desc=DAStudio.message('SimulinkHMI:dialogs:MultiStateImageDialogDesc');
    case{'SliderSwitch','ToggleSwitch','RockerSwitch'}
        desc=DAStudio.message('SimulinkHMI:dialogs:SwitchDialogDesc');
    case 'PushButton'
        desc=DAStudio.message('SimulinkHMI:dialogs:PushButtonDialogDesc');
    case 'CircularGauge'
        desc=DAStudio.message('SimulinkHMI:dialogs:CircularGaugeDialogDesc');
    case 'SemiCircularGauge'
        desc=DAStudio.message('SimulinkHMI:dialogs:SemicircularGaugeDialogDesc');
    case 'NinetyDegreeGauge'
        desc=DAStudio.message('SimulinkHMI:dialogs:NinetydegreeGaugeDialogDesc');
    case 'LinearGauge'
        desc=DAStudio.message('SimulinkHMI:dialogs:LinearGaugeDialogDesc');
    case 'ContinuousKnob'
        desc=DAStudio.message('SimulinkHMI:dialogs:ContinuousKnobDialogDesc');
    case 'Slider'
        desc=DAStudio.message('SimulinkHMI:dialogs:SliderDialogDesc');
    case 'SDIScope'
        desc=DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogDesc');
    otherwise
    end
end


function imageurl=locGetLegacyblockIcon(type)
    switch type
    case{'Lamp','DiscreteKnob','MultiStateImage','SliderSwitch'...
        ,'ToggleSwitch','RockerSwitch','PushButton','CircularGauge'...
        ,'SemiCircularGauge','NinetyDegreeGauge','LinearGauge','ContinuousKnob','Slider'...
        ,'SDIScope'}
        imageurl=sprintf(['if strcmp(get_param(bdroot(gcb),''BlockDiagramType''),',...
        '''library'')\n image([(matlabroot) ''/toolbox/simulink/hmi/icons/%s.png''])\nend'],...
        type);
    otherwise
    end
end


function helpurl=locGetLegacyblockHelp(type)
    switch type
    case 'Lamp'
        helpurl=sprintf('helpview([docroot ''/mapfiles/simulink.map''], ''hmi_lamp'')');
    case 'DiscreteKnob'
        helpurl=sprintf('helpview([docroot ''/mapfiles/simulink.map''], ''hmi_rotary_switch'')');
    case 'MultiStateImage'
        helpurl=sprintf('helpview([docroot ''/mapfiles/simulink.map''], ''hmi_multistateimage'')');
    case{'SliderSwitch','ToggleSwitch','RockerSwitch'}
        helpurl=sprintf('helpview([docroot ''/mapfiles/simulink.map''], ''hmi_switch'')');
    case 'PushButton'
        helpurl=sprintf('helpview([docroot ''/mapfiles/simulink.map''], ''hmi_pushbutton'')');
    case 'CircularGauge'
        helpurl=sprintf('helpview([docroot ''/mapfiles/simulink.map''], ''hmi_gauge'')');
    case 'SemiCircularGauge'
        helpurl=sprintf('helpview([docroot ''/mapfiles/simulink.map''], ''hmi_half_gauge'')');
    case 'NinetyDegreeGauge'
        helpurl=sprintf('helpview([docroot ''/mapfiles/simulink.map''], ''hmi_quarter_gauge'')');
    case 'LinearGauge'
        helpurl=sprintf('helpview([docroot ''/mapfiles/simulink.map''], ''hmi_linear_gauge'')');
    case 'ContinuousKnob'
        helpurl=sprintf('helpview([docroot ''/mapfiles/simulink.map''], ''hmi_knob'')');
    case 'Slider'
        helpurl=sprintf('helpview([docroot ''/mapfiles/simulink.map''], ''hmi_slider'')');
    case 'SDIScope'
        helpurl=sprintf('helpview([docroot ''/mapfiles/simulink.map''], ''hmi_scope'')');
    otherwise
    end
end


function block=locCreateSerializedBlock(obj,id,blockType,cachedProperties)


    block=struct();
    blockPath=erase(cachedProperties.blockPath,[obj.modelName,'/']);
    block.BlockPath=Simulink.BlockPath(blockPath);
    block.ShowInitialText=false;
    if isempty(cachedProperties.binding)
        block.ShowInitialText=true;
    end


    widget=struct();
    widget.id=id;
    widget.type=lower(blockType);
    widget.Enabled=true;
    widget.Width=cachedProperties.width;
    widget.Height=cachedProperties.height;
    widget.Size={cachedProperties.width,cachedProperties.height};
    widget.OuterSize=widget.Size;
    widget.Location=cachedProperties.location;
    widget.Value=NaN;
    widget.LabelPosition=simulink.hmi.getLabelPosition(cachedProperties.labelPosition);
    widget=locGetBlockSpecificProperties(widget,cachedProperties,blockType);


    block.Widget=jsonencode(widget);


    block.Source=locCreatePersistenceObject(obj,cachedProperties.binding);

end


function widget=locGetBlockSpecificProperties(widget,cachedProperties,type)
    switch type
    case 'Lamp'
        widget.OuterLocation=cachedProperties.location;
        widget.UndefinedStateColor=cachedProperties.defaultColor;
        widget.Color=cachedProperties.defaultColor;
        if isequal(numel(cachedProperties.states{1}),1)
            widget.States=cachedProperties.states(1);
            widget.StateColors=cachedProperties.states(2);
        else
            widget.States=cachedProperties.states{1};
            widget.StateColors=cachedProperties.states{2};
        end
        widget.IsSizeFixed={false,false};
        widget.AspectRatioLimits={1,1};
    case 'MultiStateImage'
        widget.OuterLocation=[0,0];
        if isscalar(cachedProperties.states)
            widget.States={[cachedProperties.states.State]};
        else
            widget.States=[cachedProperties.states.State];
        end
        widget.StateImageSizes=vertcat(cachedProperties.states.Size);
        widget.StateImages={cachedProperties.states.Image};
        widget.StateImageThumbs={cachedProperties.states.Thumbnail};

        widget.UndefinedStateImageSize=cachedProperties.defaultImage.Size;
        widget.UndefinedStateImage=cachedProperties.defaultImage.Image;
        widget.UndefinedStateImageThumb=cachedProperties.defaultImage.Thumbnail;

        widget.ScaleMode=simulink.hmi.getModePosition(cachedProperties.scaleMode);
        widget.IsSizeFixed={false,false};
        widget.AspectRatioLimits={1,1};
    case{'SliderSwitch','ToggleSwitch','RockerSwitch'}
        widget.OuterLocation=cachedProperties.location;
        widget.States=cachedProperties.states{2};
        widget.StateLabels=cachedProperties.states{1};
        widget.IsSizeFixed={false,false};
        widget.SelectedIndex=1;
        if strcmp(type,'SliderSwitch')
            widget.Orientation='horizontal';
            widget.AspectRatioLimits={0.25,0.25};
        else
            widget.Orientation='vertical';
            widget.AspectRatioLimits={0.4,0.4};
        end
    case 'DiscreteKnob'
        widget.OuterLocation=cachedProperties.location;
        widget.States=cachedProperties.values{2};
        widget.StateLabels=cachedProperties.values{1};
    case 'PushButton'
        widget.Text=cachedProperties.text;
        widget.OnValue=cachedProperties.onValue;
        widget.IsSizeFixed={false,false};
        widget.AspectRatioLimits={1,1};
    case{'CircularGauge','SemiCircularGauge','NinetyDegreeGauge','LinearGauge'}
        widget.ScaleLimits=[cachedProperties.ScaleMin,cachedProperties.ScaleMax];
        widget.AutoTickInterval=strcmpi(cachedProperties.TickInterval,'auto');
        if~widget.AutoTickInterval
            ti=str2double(cachedProperties.TickInterval);
        else
            ti=(cachedProperties.ScaleMax-cachedProperties.ScaleMin)/10;
        end
        mti=ti/5;
        widget.MajorTicks=(cachedProperties.ScaleMin:ti:cachedProperties.ScaleMax);
        widget.MinorTicks=(cachedProperties.ScaleMin:mti:cachedProperties.ScaleMax);
        widget.MajorTickLabels=cell(size(widget.MajorTicks));
        for idx=1:length(widget.MajorTickLabels)
            widget.MajorTickLabels{idx}=num2str(widget.MajorTicks(idx));
        end
        numScales=numel(cachedProperties.ScaleColors);
        widget.ScaleColorLimits=zeros(numScales,2);
        widget.ScaleColors=zeros(numScales,3);
        for idx=1:numScales
            widget.ScaleColorLimits(idx,:)=...
            [cachedProperties.ScaleColors(idx).Min...
            ,cachedProperties.ScaleColors(idx).Max];
            widget.ScaleColors(idx,:)=...
            round(255.*cachedProperties.ScaleColors(idx).Color);
        end

    case{'ContinuousKnob','Slider'}
        widget.ScaleLimits=[cachedProperties.ScaleMin,cachedProperties.ScaleMax];
        widget.AutoTickInterval=strcmpi(cachedProperties.TickInterval,'auto');
        if~widget.AutoTickInterval
            ti=str2double(cachedProperties.TickInterval);
        else
            ti=(cachedProperties.ScaleMax-cachedProperties.ScaleMin)/10;
        end
        mti=ti/5;
        widget.MajorTicks=(cachedProperties.ScaleMin:ti:cachedProperties.ScaleMax);
        widget.MinorTicks=(cachedProperties.ScaleMin:mti:cachedProperties.ScaleMax);
        widget.MajorTickLabels=cell(size(widget.MajorTicks));
        for idx=1:length(widget.MajorTickLabels)
            widget.MajorTickLabels{idx}=num2str(widget.MajorTicks(idx));
        end
        widget.ScaleType=cachedProperties.ScaleType;
    case 'SDIScope'
        widget.YAxisLimits=[cachedProperties.Ymin,cachedProperties.Ymax];
        widget.TimeSpan=cachedProperties.TimeSpan;
        widget.FitToViewAtStop=cachedProperties.FitToViewAtStop;
        widget.LegendPosition=cachedProperties.LegendPosition;

        widget.signals=struct.empty();
        for idx=1:length(cachedProperties.binding)
            blockPath=cachedProperties.binding{idx}.BlockPath.getBlock(1);
            blockPath=erase(blockPath,[cachedProperties.modelName,'/']);

            widget.signals(idx).signalUUID=cachedProperties.binding{idx}.UUID;
            widget.signals(idx).blockPath=blockPath;
            widget.signals(idx).outputPortIndex=cachedProperties.binding{idx}.OutputPortIndex;
            widget.signals(idx).signalName=cachedProperties.binding{idx}.SignalName_;
            widget.signals(idx).isDefaultColorAndStyle=true;
            widget.signals(idx).lineStyle='-';
            widget.signals(idx).lineColor=[0,0,0];
            widget.signals(idx).modelName=cachedProperties.modelName;
            widget.signals(idx).sourceBlockHandle=0;
        end

    otherwise
    end
end


function source=locCreatePersistenceObject(obj,binding)
    source=[];
    if isempty(binding)||iscell(binding)
        return
    end

    source=struct();
    blockPath=binding.BlockPath.getBlock(1);
    try
        sid=get_param(blockPath,'SID');
    catch me %#ok<NASGU>

        sid='';
    end

    blockPath=erase(blockPath,[obj.modelName,'/']);
    sid=erase(sid,[obj.modelName,':']);

    source.UUID=binding.UUID;
    source.BlockPath={blockPath};
    source.SSID={sid};

    if isprop(binding,'OutputPortIndex')
        source.Type=1;
        source.SubPath=binding.SubPath_;
        source.OutputPortIndex=binding.OutputPortIndex;
        source.SignalName=binding.SignalName_;
        source.CachedBlockHandle_=0;
    else
        source.Type=2;
        source.SubPath='';
        source.Label=binding.Label;
        source.ParamName=binding.ParamName;
        source.VarName=binding.VarName;
        source.WksType=binding.WksType;
    end
end


function locReplaceStreamingClients(obj)

    clients=get_param(obj.modelName,'StreamingClients');
    if isempty(clients)
        return
    end

    origNumClients=clients.Count;
    for idx=1:origNumClients
        curClient=get(clients,idx);
        if strcmp(curClient.ObserverType,'dashboardblocks_observer')
            curClient.ObserverType='hmi_web_widget_observer';
            if locIsClientBoundToCoreBlock(obj,curClient)
                add(clients,curClient);
            else
                set(clients,idx,curClient);
            end
        end
    end

    set_param(obj.modelName,'StreamingClients',clients);
end


function ret=locIsClientBoundToCoreBlock(obj,client)
    ret=false;
    bpath=client.getFullSignalPath();
    if bpath.getLength()
        bpath=bpath.getBlock(1);
        startIdx=length(obj.modelName)+2;
        bpathWithoutModel=bpath(startIdx:end);
        ret=Simulink.HMI.getIsBoundToDashboardBlock(obj.modelName,bpathWithoutModel);
    end
end


function locRemoveInvalidAndDupStreamingClients(obj)

    priorClients=get_param(obj.modelName,'StreamingClients');
    if isempty(priorClients)
        return
    end

    validClients=containers.Map;
    for idx=1:priorClients.Count
        curClient=get(priorClients,idx);
        if~isempty(curClient.SignalInfo)
            newKey=[curClient.SignalUUID_,curClient.ObserverType];
            validClients(newKey)=curClient;
        end
    end

    validClients=validClients.values;
    newClients=Simulink.HMI.StreamingClients(obj.modelName);
    for idx=1:length(validClients)
        add(newClients,validClients{idx});
    end
    set_param(obj.modelName,'StreamingClients',newClients);
end


function newRules=locRestoreOldStyleWebBlockId(blks)
    newRules={};
    if~isempty(blks)
        newRules=cell(1,length(blks));
        for idx=1:length(blks)
            blk=blks{idx};
            sid=slexportprevious.utils.escapeSIDFormat(get_param(blk,'SID'));
            newRules{idx}=['<Block<SID|"',sid,'">:insertpair WebBlockId "',sid,'">'];
        end
    end
end
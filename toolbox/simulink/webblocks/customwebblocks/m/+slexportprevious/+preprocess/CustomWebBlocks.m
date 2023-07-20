

function CustomWebBlocks(obj)

    blks=obj.findBlocksOfType('CustomWebBlock');
    tuningblks=obj.findBlocksOfType('CustomTuningWebBlock');
    standaloneBlks=obj.findBlocksOfType('CustomStandaloneWebBlock');
    CircularGauges={};
    LinearGauges={};
    LinearSliders={};
    Knobs={};
    Switches={};
    Buttons={};
    CallbackButtons={};
    Lamps={};



    if~isempty(blks)
        for blkIdx=1:size(blks)
            blk=blks{blkIdx};

            handle=get_param(blk,'Handle');
            name=get_param(handle,'Name');
            config=jsondecode(get_param(handle,'Configuration'));
            customType=get_param(handle,'CustomType');
            if strcmp(customType,'Circular Gauge')
                CircularGauges{end+1}={handle,name,config};
            elseif strcmp(customType,'Horizontal Gauge')||...
                strcmp(customType,'Vertical Gauge')
                LinearGauges{end+1}={handle,name,config};
            elseif strcmp(customType,'Lamp')
                Lamps{end+1}={handle,name,config};
            end
        end
    end

    if~isempty(tuningblks)
        for blkIdx=1:size(tuningblks)
            blk=tuningblks{blkIdx};

            handle=get_param(blk,'Handle');
            name=get_param(handle,'Name');
            config=jsondecode(get_param(handle,'Configuration'));
            customType=get_param(handle,'CustomType');
            if strcmp(customType,'Knob')
                Knobs{end+1}={handle,name,config};
            elseif strcmp(customType,'Horizontal Slider')||...
                strcmp(customType,'Vertical Slider')
                LinearSliders{end+1}={handle,name,config};
            elseif strcmp(customType,'Switch')
                Switches{end+1}={handle,name,config};
            elseif strcmp(customType,'Push Button')||...
                strcmp(customType,'Callback Button')
                Buttons{end+1}={handle,name,config};
            end
        end
    end

    if~isempty(standaloneBlks)
        for blkIdx=1:size(standaloneBlks)
            blk=standaloneBlks{blkIdx};

            handle=get_param(blk,'Handle');
            name=get_param(handle,'Name');
            config=jsondecode(get_param(handle,'Configuration'));
            customType=get_param(handle,'CustomType');
            if strcmp(customType,'Callback Button')
                CallbackButtons{end+1}={handle,name,config};
            end
        end
    end



    if obj.ver.isReleaseOrEarlier('R2021a')
        locRemoveCustomBackgroundColor(obj,blks,tuningblks,standaloneBlks);
    end



    if~isempty(LinearGauges)

        if obj.ver.isReleaseOrEarlier('R2022a')
            locModifyScaleColors(obj,LinearGauges);
        end

        if obj.ver.isReleaseOrEarlier('R2020a')
            locModifyLinearGauges(obj,LinearGauges);
        end

        if obj.ver.isReleaseOrEarlier('R2019b')
            locRemoveCustomBlocks(obj,LinearGauges);
        end
    end


    if~isempty(CircularGauges)

        if obj.ver.isReleaseOrEarlier('R2022a')
            locModifyScaleColors(obj,CircularGauges);
        end

        if obj.ver.isReleaseOrEarlier('R2020a')
            locReplaceCircularGauge(obj,CircularGauges);
        end

        if obj.ver.isReleaseOrEarlier('R2018b')
            locRemoveCustomBlocks(obj,CircularGauges);
        end
    end


    if~isempty(LinearSliders)

        if obj.ver.isReleaseOrEarlier('R2020b')
            locRemoveCustomBlocks(obj,LinearSliders);
        end
    end


    if~isempty(Knobs)

        if obj.ver.isReleaseOrEarlier('R2020b')
            locRemoveCustomBlocks(obj,Knobs);
        end
    end


    if~isempty(Lamps)

        if obj.ver.isReleaseOrEarlier('R2021a')
            locRemoveCustomBlocks(obj,Lamps);

        elseif obj.ver.isReleaseOrEarlier('R2021b')
            locRollback22aLamps(obj,Lamps);
        end
    end


    if~isempty(Switches)

        if obj.ver.isReleaseOrEarlier('R2021a')
            locRemoveCustomBlocks(obj,Switches);
        end
    end

    if~isempty(Buttons)

        if obj.ver.isReleaseOrEarlier('R2021a')
            locRemoveCustomBlocks(obj,Buttons);
        end
    end

    if~isempty(CallbackButtons)

        if obj.ver.isReleaseOrEarlier('R2021a')
            locRemoveCustomBlocks(obj,CallbackButtons);
        end
    end
end


function locModifyScaleColors(obj,blks)
    if~isempty(blks)
        for blkIdx=1:size(blks,2)
            blk=blks{blkIdx};

            handle=blk{1};
            config=blk{3};
            func=@(x)strcmp(config.components(x).name,'LinearScaleComponent')||...
            strcmp(config.components(x).name,'CircularScaleComponent');
            index=find(arrayfun(func,1:numel(config.components)));
            scaleColors=config.components(index).settings.scaleColors;
            for scIdx=1:length(scaleColors)
                scaleColor=scaleColors(scIdx);
                if isfield(scaleColor,'Min')
                    scaleColor.min=scaleColor.Min;
                    scaleColor.max=scaleColor.Max;
                    scaleColor.color=scaleColor.Color/255;
                end
                scaleColors(scIdx)=scaleColor;
            end
            config.components(index).settings.scaleColors=scaleColors;
            modifiedBlk=getfullname(handle);
            set_param(modifiedBlk,'Configuration',jsonencode(config));
        end
    end
end


function locRemoveCustomBackgroundColor(obj,blks,tuningBlks,standaloneBlks)
    blocks=[blks;tuningBlks;standaloneBlks];
    rule=sprintf('<BlockParameterDefaults<Block<BlockType|"CustomWebBlock"><CustomBackgroundColor:remove>>>');
    obj.appendRule(rule);
    rule=sprintf('<BlockParameterDefaults<Block<BlockType|"CustomTuningWebBlock"><CustomBackgroundColor:remove>>>');
    obj.appendRule(rule);
    for blkIdx=1:length(blocks)
        blk=blocks(blkIdx);
        handle=get_param(blk{1},'Handle');
        name=get_param(blk{1},'Name');
        customParam=jsondecode(get_param([obj.origModelName,'/',name],'CustomBackgroundColor'));
        configParam=jsondecode(get_param([obj.origModelName,'/',name],'Configuration'));
        configParam.settings.backgroundColor=customParam.color;
        configParam.settings.showBackgroundColor=customParam.show;
        modifiedBlk=getfullname(handle);
        set_param(modifiedBlk,'Configuration',jsonencode(configParam));

        sid=get_param(blk{1},'SID');
        rule=sprintf('<Block<SID|"%s"><CustomBackgroundColor:remove>>',sid);
        obj.appendRule(rule);
    end
end


function locReplaceCircularGauge(obj,blks)
    if~isempty(blks)
        for blkIdx=1:size(blks,2)
            blk=blks{blkIdx};
            handle=blk{1};
            name=blk{2};
            binding=get_param([obj.origModelName,'/',name],'BindingPersistence');
            paramNames={...
            'LabelPosition',...
            'ScaleMin',...
            'ScaleMax',...
            'TickInterval',...
            'ScaleColors',...
            'fixedAspectRatio',...
            'GaugeMin',...
            'GaugeMax',...
            'GaugeArcDefined',...
            'GaugeArcRadius',...
            'GaugeArcStrokeWidth',...
            'GaugeArcColor',...
            'GaugeArcRotation',...
            'GaugeArcRatio',...
            'GaugeArcTransparency',...
            'ValueArcTransparency',...
            'ValueArcColor',...
            'GaugeTickVisible',...
            'GaugeTickTransparency',...
            'GaugeTickColor',...
            'ScaleColorsJSON',...
            'CenterOffsetX',...
            'CenterOffsetY',...
            'NeedleImage',...
            'NeedleXPos',...
            'NeedleYPos',...
            'NeedleHeight',...
            'NeedleWidth',...
            'NeedleInitialRotation',...
'BackgroundImage'...
            };

            paramStruct=struct;
            for prmIdx=1:size(paramNames,2)
                paramName=paramNames{prmIdx};
                value=get_param([obj.origModelName,'/',name],paramName);
                paramStruct=setfield(paramStruct,paramName,value);
            end



            if isequal(paramStruct.TickInterval,'-1')
                paramStruct.TickInterval='auto';
            end


            paramStruct.ScaleColorsJSON=jsonencode(paramStruct.ScaleColors);
            paramStruct=rmfield(paramStruct,'ScaleColors');

            nv=namedargs2cell(paramStruct);


            replacedBlk=getfullname(handle);
            sid=get_param(replacedBlk,'SID');
            rule=sprintf('<Block<SID|"%s"><BlockType|"CustomWebBlock":repval "CustomGaugeBlock">>',sid);
            obj.appendRule(rule);
            rule=sprintf('<Block<SID|"%s"><Configuration:remove>>',sid);
            obj.appendRule(rule);
            rule=sprintf('<Block<SID|"%s"><updateConfig:remove>>',sid);
            obj.appendRule(rule);
            rule=sprintf('<Block<SID|"%s"><dlgMetadata:remove>>',sid);
            obj.appendRule(rule);

            for idx=1:2:size(nv,2)
                escapedValue=slexportprevious.utils.escapeRuleCharacters(nv{idx+1});
                escapedValue=strrep(escapedValue,'"','&"');
                rule=sprintf('<Block<SID|"%s">:insertpair %s "%s">',sid,nv{idx},escapedValue);
                obj.appendRule(rule);
            end
        end
    end
end


function locModifyLinearGauges(obj,blks)
    if~isempty(blks)
        for blkIdx=1:size(blks,2)
            blk=blks{blkIdx};

            handle=blk{1};
            name=blk{2};
            config=blk{3};
            func=@(x)strcmp(config.components(x).name,'ForegroundImageComponent');
            index=find(arrayfun(func,1:numel(config.components)));
            config.components(index)=[];
            modifiedBlk=getfullname(handle);
            set_param(modifiedBlk,'Configuration',jsonencode(config));
        end
    end
end


function locRollback22aLamps(~,blks)
    shapeTypes={'ellipse','rectangle','triangle'};
    for blkIdx=1:size(blks,2)
        blk=blks{blkIdx};
        handle=blk{1};
        config=blk{3};

        func=@(x)strcmp(config.components(x).name,'LampStateComponent');
        index=find(arrayfun(func,1:numel(config.components)));
        lampStateComponent=config.components(index);

        defaultState=lampStateComponent.settings.states(1);
        lampShapeComponent.name='LampShapeComponent';
        lampShapeComponent.settings.customMask.src=defaultState.icon.customSrc;
        lampShapeComponent.settings.customMask.srcOrientation=defaultState.icon.srcOrientation;
        lampShapeComponent.settings.defaultColor=defaultState.shape.color;
        lampShapeComponent.settings.mask.id=defaultState.icon.id;
        lampShapeComponent.settings.mask.type=defaultState.icon.type;
        lampShapeComponent.settings.maskScale=defaultState.iconScale;
        lampShapeComponent.settings.position=defaultState.shape.position;
        lampShapeComponent.settings.shapeId=find(...
        strcmp(shapeTypes,defaultState.shape.type))-1;
        if numel(lampStateComponent.settings.states)>1
            lampShapeComponent.settings.states=arrayfun(...
            @(s)locRollback22aLampState(s),...
            lampStateComponent.settings.states(2:end));
        else
            lampShapeComponent.settings.states=[];
        end
        lampShapeComponent.settings.type=defaultState.overlayType;


        config.components(index)=lampShapeComponent;
        set_param(handle,'Configuration',jsonencode(config));
    end
end

function oldState=locRollback22aLampState(newState)
    value=newState.value;
    if isstruct(value)&&isfield(value,'min')
        value=value.min;
        if strcmp(value,'-inf')
            value=realmin;
        end
    end
    if ischar(value)
        value=str2double(value);
    end
    oldState.value=value;
    oldState.color=newState.shape.color;
end


function locRemoveCustomBlocks(obj,blks)
    if~isempty(blks)
        for blkIdx=1:size(blks,2)
            blk=blks{blkIdx};
            handle=blk{1};
            obj.replaceWithEmptySubsystem(handle);
        end
    end
end

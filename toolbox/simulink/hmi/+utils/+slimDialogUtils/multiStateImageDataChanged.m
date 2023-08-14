


function multiStateImageDataChanged(dlgSrc,widgetId,mdl,isLibWidget)
    if isa(dlgSrc,'hmiblockdlg.MultiStateImageBlock')
        coreBlockChanged(dlgSrc)
    else
        widget=utils.getWidget(mdl,widgetId,isLibWidget);
        if~isempty(widget)
            legacyBlockChanged(dlgSrc,widgetId,mdl,widget)
        end
    end
end


function coreBlockChanged(dlgSrc)
    scChannel='/hmi_multiStateImage_controller_/';
    blockHandle=get(dlgSrc.blockObj,'handle');


    dlgs=dlgSrc.getOpenDialogs(true);
    dlg=[];
    for idx=1:length(dlgs)
        dlg=dlgs{1};
        if~dlg.isStandAlone
            break
        end
    end


    invStateIndexes=[];
    states=[];
    success=true;
    for idx=1:length(dlgSrc.States)
        if ischar(dlgSrc.States(idx).State)
            dlgSrc.States(idx).State=str2double(dlgSrc.States(idx).State);
        end
        data=dlgSrc.States(idx).State;
        if isempty(data)||~isreal(data)||isnan(data)||isinf(data)
            invStateIndexes{end+1}={idx};%#ok<*AGROW>
            success=false;
        else
            states=[states,data];
        end
    end
    if~success
        message.publish([scChannel,'showInvalidStateData'],invStateIndexes);
        return;
    end


    if length(states)>length(unique(states))


        dupMap=containers.Map('KeyType','double','ValueType','any');
        dupMap(states(1))={1};
        for idx=2:length(states)
            if~dupMap.isKey(states(idx))
                temp={};
            else
                temp=dupMap(states(idx));
            end

            temp{length(temp)+1}=idx;
            dupMap(states(idx))=temp;
        end


        dupStateCellArr={};
        dupMapKeys=dupMap.keys();
        for idx=1:length(dupMapKeys)
            if length(dupMap(dupMapKeys{idx}))>1
                dupStateCellArr{length(dupStateCellArr)+1}=dupMap(dupMapKeys{idx});
            end
        end


        message.publish([scChannel,'showDuplicateStates'],dupStateCellArr);
        return
    end


    defImage=dlgSrc.DefaultImage;
    set_param(blockHandle,'States',dlgSrc.States);
    set_param(blockHandle,'DefaultImage',defImage);


    newLabelPosition=dlg.getComboBoxText('labelPosition');
    currentLabelPosition=get_param(blockHandle,'LabelPosition');
    if~strcmp(currentLabelPosition,newLabelPosition)
        newLabelPosition=simulink.hmi.getLabelPosition(newLabelPosition);
        set_param(blockHandle,'LabelPosition',newLabelPosition);
    end


    newMode=simulink.hmi.getModePosition(dlg.getComboBoxText('scaleModeEdit'));
    curMode=get_param(blockHandle,'ScaleMode');
    curMode=simulink.hmi.getModePosition(curMode);
    if newMode~=curMode
        set_param(blockHandle,'ScaleMode',newMode);
    end
end


function legacyBlockChanged(dlgSrc,widgetId,mdl,widget)
    scChannel='/hmi_multiStateImage_controller_/';
    multiStateImageData={};

    if~isempty(dlgSrc.States)

        invStateIndexes=[];
        states=[];
        success=true;
        for idx=1:length(dlgSrc.States)
            data=dlgSrc.States{idx};
            if isequal('char',class(data))
                data=str2double(data);
            end
            if isempty(data)||~isreal(data)||isnan(data)||isinf(data)
                invStateIndexes{end+1}={idx};
                success=false;
            else
                states=[states,data];
            end
        end


        if isequal(success,false)
            message.publish([scChannel,'showInvalidStateData'],...
            invStateIndexes);
            return;
        end


        if length(states)>length(unique(states))


            dupMap=containers.Map('KeyType','double','ValueType','any');
            dupMap(states(1))={1};
            for idx=2:length(states)
                if~dupMap.isKey(states(idx))
                    temp={};
                else
                    temp=dupMap(states(idx));
                end
                temp{length(temp)+1}=idx;
                dupMap(states(idx))=temp;
            end

            dupStateCellArr={};
            dupMapKeys=dupMap.keys();
            for idx=1:length(dupMapKeys)
                if length(dupMap(dupMapKeys{idx}))>1
                    dupStateCellArr{length(dupStateCellArr)+1}=dupMap(dupMapKeys{idx});
                end
            end


            message.publish([scChannel,'showDuplicateStates'],...
            dupStateCellArr);
            return;
        end


        widget.States=states;
        widget.StateImageSizes=dlgSrc.StateImageSizes;
        widget.StateImages=dlgSrc.StateImages;
        widget.StateImageThumbs=dlgSrc.StateImageThumbs;
        widget.UndefinedStateImageSize=dlgSrc.UndefinedStateImageSize;
        widget.UndefinedStateImage=dlgSrc.UndefinedStateImage;
        widget.UndefinedStateImageThumb=dlgSrc.UndefinedStateImageThumb;
    end


    multiStateImageData{1}=dlgSrc.States;
    multiStateImageData{2}={''};
    multiStateImageData{3}=dlgSrc.StateImageThumbs;
    multiStateImageData{4}={};
    multiStateImageData{5}={''};
    multiStateImageData{6}=dlgSrc.UndefinedStateImageThumb;
    multiStateImageData{7}={};
    multiStateImageData{8}=dlgSrc.ScaleMode;
    message.publish([scChannel,'updateProperties'],...
    {true,widgetId,mdl,multiStateImageData});

    set_param(mdl,'Dirty','on');
end

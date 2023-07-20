


function[success,errormsg]=preApplyCB(obj,dlg)
    success=true;
    errormsg='';
    blockHandle=get(obj.blockObj,'handle');
    mdl=get_param(bdroot(blockHandle),'Name');
    if Simulink.HMI.isLibrary(mdl)
        return;
    end

    dlgSrc=dlg(1).getSource;
    scChannel='/hmi_multiStateImage_controller_/';


    invStateIndexes=[];
    states=[];
    thumbs=[];
    for idx=1:length(dlgSrc.States)
        if ischar(dlgSrc.States(idx).State)
            dlgSrc.States(idx).State=str2double(dlgSrc.States(idx).State);
        end
        data=dlgSrc.States(idx).State;
        thumb=dlgSrc.States(idx).Thumbnail;
        if isempty(data)||~isreal(data)||isnan(data)||isinf(data)
            invStateIndexes{end+1}={idx};%#ok<*AGROW>
            success=false;
        else
            states=[states,data];
            thumbs=[thumbs,thumb];
        end
    end
    if~success
        errormsg=DAStudio.message('SimulinkHMI:dialogs:NonNumericStatesError');
        message.publish([scChannel,'showInvalidStateData'],invStateIndexes);
        return;
    end


    if length(states)>length(unique(states))
        errormsg=DAStudio.message('SimulinkHMI:dialogs:MultiStateImageNonUniqueStatesError');
        success=false;


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


    newLabelPosition=simulink.hmi.getLabelPosition(...
    dlg.getComboBoxText('labelPosition'));

    newMode=simulink.hmi.getModePosition(...
    dlg.getComboBoxText('scaleMode'));

    set_param(blockHandle,'States',dlgSrc.States,...
    'DefaultImage',dlgSrc.DefaultImage,...
    'LabelPosition',newLabelPosition,...
    'ScaleMode',newMode);


    bindSignal(obj);
    set_param(mdl,'Dirty','on');


    dlgs=dlgSrc.getOpenDialogs(true);
    for idx=1:length(dlgs)
        dlgs{idx}.enableApplyButton(false,false);
        if~isequal(dlg,dlgs{idx})
            multiStateImageData{1}=cellfun(@num2str,{dlgSrc.States.State},'UniformOutput',false);
            multiStateImageData{2}={''};
            multiStateImageData{3}={dlgSrc.States.Thumbnail};
            multiStateImageData{4}={};
            multiStateImageData{5}={''};
            multiStateImageData{6}={dlgSrc.DefaultImage.Thumbnail};
            multiStateImageData{7}={};
            multiStateImageData{8}=num2str(newMode);
            message.publish([scChannel,'updateProperties'],...
            {false,obj.widgetId,mdl,multiStateImageData});
        end
    end
end

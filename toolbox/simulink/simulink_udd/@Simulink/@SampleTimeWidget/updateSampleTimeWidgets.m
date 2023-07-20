function updateSampleTimeWidgets(blockHandle)






    dlgs=DAStudio.ToolRoot.getOpenDialogs;
    for i=1:length(dlgs)
        updateOneSampleTimeDialog(dlgs(i),blockHandle);
    end

end

function updateOneSampleTimeDialog(dlg,blockHandle)


    src=dlg.getSource;
    blk=src.getBlock;
    thisHandle=get_param(blk.getFullName,'Handle');
    if thisHandle~=blockHandle

        return
    end

    imd=DAStudio.imDialog.getIMWidgets(dlg);
    allWidgets=imd.find();
    allTags=get(allWidgets(2:end),'Tag');

    idx=find(~cellfun(@(a)isempty(a),...
    strfind(allTags,'|ASTWValuePanel')));

    for i=1:length(idx)
        tag=allTags{idx(i)};
        stTag=strtok(tag,'|');
        stUserData=dlg.getUserData(stTag);
        stTypeTag=stUserData{2};
        stTypeParamName=stUserData{3};
        updateOneSampleTimeWidget(dlg,stTag,stTypeTag,stTypeParamName);
    end

end

function updateOneSampleTimeWidget(dlg,stTag,stTypeTag,stTypeParamName)





    typeVal=dlg.getComboBoxText(stTypeTag);

    [type,storedValue]=localGetTypeAndValue(...
    dlg.getWidgetValue(stTag),typeVal);


    switch type
    case 'Periodic'
        dlg.setWidgetValue([stTag,'|periodicPanel_value'],storedValue.string);
    case 'Unresolved'
        dlg.setWidgetValue([stTag,'|unresolvedPanel_value'],storedValue.string);
    otherwise

    end




    if isempty(stTypeParamName)
        for attemptedIndex=0:5
            dlg.setWidgetValue([stTag,'|advSTWidgetCombobox'],attemptedIndex);
            if strcmp(dlg.getComboBoxText([stTag,'|advSTWidgetCombobox']),...
                localGetNameFromType(type))
                break
            end
        end
    end



    Simulink.SampleTimeWidget.callbackAdvancedSampleTimeWidget(...
    'callback_combobox',dlg,stTag,stTypeTag);

end



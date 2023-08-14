function widgetChanged(hObj,hDlg,tag,~)





    if isempty(hDlg.getUserData(tag))
        tagprefix='Tag_ConfigSet_RTT_Settings_';
        fieldName=strrep(tag,tagprefix,'');
        hObj.TargetExtensionData.(fieldName)=hDlg.getWidgetValue(tag);
    else
        UserDatas=hDlg.getUserData(tag);



        if(iscell(UserDatas)&&(length(UserDatas)>1))
            eval(UserDatas{1});
        else
            eval(hDlg.getUserData(tag));
        end

    end

end

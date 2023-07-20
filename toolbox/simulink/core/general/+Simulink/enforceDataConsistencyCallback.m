function enforceDataConsistencyCallback(ddgDialogObj,dialogH,value)



    mdlName=dialogH.name;
    if value==0
        setting='off';
    else
        setting='on';
    end
    set_param(mdlName,'EnforceDataConsistency',setting);
    ddgDialogObj.clearWidgetDirtyFlag('EnforceDataConsistency');
end

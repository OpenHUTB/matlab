function targetChangedCallback(hThis,dlg,tag,value)

















    ud=dlg.getUserData(tag);
    val=lFindItem(hThis.Items,ud.BlockParameter);
    if isnumeric(value)&&isprop(val,'Choices')
        val.Value=val.Choices{value+1};
    else
        val.Value=value;
    end


    spec=lFindItem(hThis.Items,ud.SpecifyParameter);
    spec.Value=true;





    paramWidgetTag=regexp(tag,'.*(?=_default$)','match','once');
    dlg.setWidgetValue(paramWidgetTag,value);
    specifyTag=[spec.ObjId,'.',ud.BaseParam,'_specify.','Check'];
    dlg.setWidgetValue(specifyTag,true);
    dlg.getSource().updateDialogVisibilities(dlg);


    dlg.setWidgetValue(tag,ud.DefaultValue);
    dlg.clearWidgetDirtyFlag(tag);
end

function item=lFindItem(items,param)
    params=arrayfun(@(item)item.ValueBlkParam,items,...
    'UniformOutput',false);
    item=items(strcmp(params,param));
end
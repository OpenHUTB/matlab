function[data,meta]=getDeploymentTypeData(obj,id,role)

    node=obj.dataModel.getNode(id);

    automaticText=message('ToolstripCoderApp:toolstrip:DeploymentTypeAutoText').getString;
    componentText=message('ToolstripCoderApp:toolstrip:DeploymentTypeComponentText').getString;
    subcomponentText=message('ToolstripCoderApp:toolstrip:DeploymentTypeSubAssemblyText').getString;

    automaticIcon=connector.getBaseUrl('toolbox/shared/toolstrip_coder_app/plugin/icons/sdp/Automatic_16.png');
    componentIcon=connector.getBaseUrl('toolbox/shared/toolstrip_coder_app/plugin/icons/sdp/Component_16.png');
    subcomponentIcon=connector.getBaseUrl('toolbox/shared/toolstrip_coder_app/plugin/icons/sdp/Subcomponent_16.png');

    dict=obj.dataModel.getCoderDictionary(id);
    type=simulinkcoder.internal.sdp.util.getCodeInterfaceType(dict);

    data=mdom.Data;
    if role==0
        label='';
        icon='';
    elseif role==1
        dt=node.DeploymentType;
        if dt==2
            label=subcomponentText;
            icon=subcomponentIcon;
        else
            if type==1
                label=automaticText;
                icon=automaticIcon;
            elseif type==2
                label=componentText;
                icon=componentIcon;
            end
        end
    elseif role==2
        label=subcomponentText;
        icon=subcomponentIcon;
    end
    data.setProp('label',label);
    data.setProp('iconUri',icon);

    meta=mdom.MetaData;
    if role==1
        meta.setProp('editor','ComboboxEditor');

        items=[];
        item=mdom.MetaData;
        item.registerDataType('value',mdom.MetaDataType.INT);


        item.setProp('value',1);
        if type==1
            item.setProp('label',automaticText);
        elseif type==2
            item.setProp('label',componentText);
        end
        items=[items,item];


        item.clear();
        item.setProp('value',2);
        item.setProp('label',subcomponentText);
        items=[items,item];

        meta.setProp('items',items);
    end





function fontSizeRF(userdata,cbinfo,action)
    action.enabled=false;
    needDefaultValue=strcmp(userdata,'select');
    defaultValue=0;
    selection=cbinfo.selection;

    for j=1:selection.size
        obj=selection.at(j);


        type=obj.MetaClass.qualifiedName;
        if~strcmp(type,'SLM3I.Connector')&&...
            ~strcmp(type,'markupM3I.MarkupItem')&&...
            ~strcmp(type,'markupM3I.MarkupConnector')&&...
            ~SLStudio.toolstrip.internal.objIsImage(obj)&&...
            ~SLStudio.Utils.isPanelWebBlock(obj)

            action.enabled=true;


            if~needDefaultValue
                break;
            end


            if strcmp(obj.MetaClass.qualifiedName,'SLM3I.Segment')||...
                strcmp(obj.MetaClass.qualifiedName,'SLM3I.SolderJoint')||...
                strcmp(obj.MetaClass.qualifiedName,'SLM3I.Port')
                obj=obj.container;
            end


            if defaultValue==0
                defaultValue=obj.font.Size;
            elseif defaultValue~=obj.font.Size
                defaultValue=0;
                break;
            end
        end
    end


    if needDefaultValue
        action.setSelectedItemWithDefault(num2str(defaultValue),'');
    end
end

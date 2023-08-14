



function fontStyleRF(userdata,cbinfo,action)
    action.enabled=false;
    action.selected=0;
    selection=cbinfo.selection;

    for j=1:selection.size
        obj=selection.at(j);


        type=obj.MetaClass.qualifiedName;
        if~strcmp(type,'SLM3I.Connector')&&...
            ~strcmp(type,'markupM3I.MarkupItem')&&...
            ~strcmp(type,'markupM3I.MarkupConnector')&&...
            ~SLStudio.toolstrip.internal.objIsImage(obj)&&...
            ~SLStudio.Utils.isPanelWebBlock(obj)


            if strcmp(obj.MetaClass.qualifiedName,'SLM3I.Segment')||...
                strcmp(obj.MetaClass.qualifiedName,'SLM3I.SolderJoint')||...
                strcmp(obj.MetaClass.qualifiedName,'SLM3I.Port')
                obj=obj.container;
            end

            switch userdata
            case 'bold'
                action.enabled=true;
                if strcmp(obj.font.Weight,'Normal')

                    action.selected=0;
                    return;
                end
                action.selected=1;
            case 'italic'
                action.enabled=true;
                if strcmp(obj.font.Style,'Normal')

                    action.selected=0;
                    return;
                end
                action.selected=1;
            case 'latex'
                if strcmp(obj.MetaClass.qualifiedName,'SLM3I.Annotation')&&...
                    (obj.Type~=SLM3I.AnnotationType.AREA_ANNOTATION)
                    action.enabled=true;
                    if obj.TeXMode~=1

                        action.selected=0;
                        return;
                    end
                    action.selected=1;
                end
            otherwise
                error('Bad option passed to fontStyleRF');
            end
        end
    end
end

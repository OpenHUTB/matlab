



function fontNameRF(cbinfo,action)
    action.enabled=false;
    action.validateAndSetEntries(MG2.Font.getInstalledFontNames());
    defaultValue='';
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


            if strcmp(type,'SLM3I.Segment')||...
                strcmp(type,'SLM3I.SolderJoint')||...
                strcmp(type,'SLM3I.Port')
                obj=obj.container;
            end


            if isempty(defaultValue)
                defaultValue=obj.font.actualFontName;
            elseif~strcmp(defaultValue,obj.font.actualFontName)
                defaultValue='';
                break;
            end
        end
    end
    action.setSelectedItemWithDefault(defaultValue,'');
end

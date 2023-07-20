



function sfFontSizeRF(userdata,cbinfo,action)
    action.enabled=false;
    needDefaultValue=strcmp(userdata,'select');
    defaultValue=0;


    selection=cbinfo.selection;
    for j=1:selection.size


        obj=selection.at(j);
        if~isempty(obj)&&~isa(obj,'StateflowDI.Junction')&&...
            ~isa(obj,'markupM3I.MarkupItem')&&...
            ~isa(obj,'markupM3I.MarkupConnector')
            action.enabled=true;


            if~needDefaultValue
                break;
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

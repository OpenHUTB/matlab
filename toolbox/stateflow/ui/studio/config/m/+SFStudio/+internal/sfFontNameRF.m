



function sfFontNameRF(cbinfo,action)
    action.enabled=false;
    action.validateAndSetEntries(MG2.Font.getInstalledFontNames());
    defaultValue='';


    selection=cbinfo.selection;
    for j=1:selection.size

        obj=selection.at(j);
        if~isempty(obj)&&~isa(obj,'StateflowDI.Junction')







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

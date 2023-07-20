



function junctionSizeRF(userdata,cbinfo,action)
    action.enabled=false;
    needDefaultValue=strcmp(userdata,'select');
    defaultValue=0;


    selection=cbinfo.selection;
    for j=1:selection.size


        obj=selection.at(j);
        if~isempty(obj)&&(isa(obj,'StateflowDI.Junction')||isa(obj,'StateflowDI.Port'))
            action.enabled=true;


            if~needDefaultValue
                break;
            end

            if defaultValue==0
                defaultValue=obj.size(1);


            elseif defaultValue~=obj.size(1)
                defaultValue=0;
                break;
            end
        end
    end


    if needDefaultValue
        action.setSelectedItemWithDefault(num2str(defaultValue),'');
        if isempty(action.selectedItem)&&defaultValue~=0
            action.placeholderText=num2str(defaultValue);
        else
            action.placeholderText='';
        end
    end
end

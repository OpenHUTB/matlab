



function arrowheadSizeRF(userdata,cbinfo,action)
    action.enabled=false;
    needDefaultValue=strcmp(userdata,'select');
    defaultValue=0;


    selection=cbinfo.selection;
    for j=1:selection.size


        obj=selection.at(j);
        if isprop(obj,'backendId')&&obj.backendId~=0
            t=SFStudio.Utils.getType(double(obj.backendId));
            types=SFStudio.Utils.getType;
            if t.type==types.OR_STATE||t.type==types.AND_STATE||...
                t.type==types.BOX||t.type==types.JUNCT||t.type==types.TRANS||t.type==types.PORT


                if t.type==types.TRANS
                    obj=obj.dstElement;
                    if~obj.isvalid||isa(obj,'StateflowDI.Subviewer')
                        continue;
                    end
                end

                action.enabled=true;
                if~needDefaultValue

                    break;
                end

                if defaultValue==0
                    defaultValue=obj.arrowSize;
                elseif defaultValue~=obj.arrowSize

                    defaultValue=0;
                    break;
                end
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

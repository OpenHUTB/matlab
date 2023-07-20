function setDirty(obj)
    t=obj.getDialogSchema('ModelDDLinksButtonPanel');
    openDialogs=DAStudio.ToolRoot.getOpenDialogs;

    thisObj='';
    if(~isempty(openDialogs))
        for i=1:length(openDialogs)
            if isequal(openDialogs(i).getDialogSource,obj)
                thisObj=openDialogs(i);
                break;
            end
        end
    end

    if~isempty(thisObj)
        thisObj.setEnabled('ModelDDLinks_Apply',true);
    end
end

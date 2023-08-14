function[item,isNew]=ensureLinkableItem(this,linkSetObj,srcStruct)






    isNew=false;

    if isfield(srcStruct,'domain')&&isfield(srcStruct,'sid')&&~isempty(srcStruct.sid)

        srcStruct.id=num2str(srcStruct.sid);
    end

    item=this.findLinkableItem(linkSetObj,srcStruct);
    if isempty(item)
        item=this.addLinkableItem(linkSetObj,srcStruct);
        isNew=true;
    end
end

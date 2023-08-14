function wasDeleted=doDelete(this,~)




    wasDeleted=false;

    if~isLibrary(this)
        try
            if~isempty(findprop(this,'ID'))
                id=this.ID;
            else
                id='';
            end

            parentNode=this.JavaHandle.getParentNode;
            if~isempty(parentNode)
                parentNode.removeChild(this.JavaHandle);
            end
            parentObj=this.up;
            disconnect(this);
            delete(this);
            wasDeleted=true;
            if~isempty(parentObj)
                parentObj.setDirty(true);
                if~isempty(id)
                    RptgenML.checkDuplicateStylesheetID(parentObj,id);
                end
            end
        catch ME
            warning(ME.message);
        end
    end



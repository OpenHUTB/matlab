function removeExclusionCallback(this,~)




    si=1;
    while true
        rowIdx=this.fDialogHandle.getSelectedTableRow('ModelExclusionsTable')+si;
        if this.tableIdxMap.isKey(rowIdx)
            prop=this.tableIdxMap(rowIdx);
            if(isfield(prop,'value')&&(strcmp(prop.value,'InactiveRegions')||strcmp(prop.value,'LibraryLinks')||strcmp(prop.value,'ModelReference')))
                si=si+1;
                continue;
            end
            this.removeExclusionByProp(prop,this.activeTabIndex==0);
        end
        break;
    end

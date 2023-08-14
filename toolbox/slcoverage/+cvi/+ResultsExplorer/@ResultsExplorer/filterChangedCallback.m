function filterChangedCallback(explrObj,event,filterId)







    activeTree=explrObj.root.activeTree;
    cumNode=activeTree.root;
    cumNodeData=cumNode.data;


    if strcmpi(event,'new')

        allFilterIds=cumNode.getAppliedFilterIds();
        allFilterIds=[allFilterIds,{filterId}];
        cumNode.setAppliedFilterIds(allFilterIds);
    elseif strcmpi(event,'remove')
        allFilterIds=cumNode.getAppliedFilterIds();
        allFilterIds(allFilterIds==string(filterId))=[];

        cumNode.setAppliedFilterIds(allFilterIds);
    elseif strcmpi(event,'replace')
        allFilterIds=cumNode.getAppliedFilterIds();
        oldFilterId=filterId{1};
        newFilterId=filterId{2};
        allFilterIds{allFilterIds==string(oldFilterId)}=newFilterId;
        cumNode.setAppliedFilterIds(allFilterIds);
    end

    if~strcmpi(event,'new')&&~strcmpi(event,'replace')
        if~isempty(cumNodeData)
            cvdNeedsUpdated=true;
            if cumNode.isHighlighted()
                cumNode.modelview();
                cvdNeedsUpdated=false;
            end
            if~isempty(cumNodeData.lastReport)
                cumNodeData.resetLastReport;
                cumNode.createReport();
                cvdNeedsUpdated=false;
            end
            if cvdNeedsUpdated
                if cumNode.isActiveRoot
                    cumNode.applyFilter;
                end
            end
            cumNodeData.resetSummary();
            explrObj.dataChange(cumNode);
        end
    end

end


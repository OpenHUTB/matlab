function[matchingIDs,treeIDs,filtitems]=executeFilter(this)
















    itemnames=this.ItemNames;

    filterkey=this.getFilterText();
    regexpsupport=this.getRegularExpression;
    if~isempty(filterkey)
        if regexpsupport
            matchingIDs=find(~cellfun(@isempty,regexp(itemnames,filterkey)));
        else
            matchingIDs=find(~cellfun(@isempty,strfind(itemnames,filterkey)));
        end

        if~this.getFlatList()
            fullchildtable=this.ChildrenHash;
            child2add=[];
            for ct=1:numel(matchingIDs)
                thisid=matchingIDs(ct);
                child2add(end+1:end+numel(fullchildtable{thisid}))=fullchildtable{thisid};
            end
            matchingIDs=union(matchingIDs,child2add);
        end
        treeIDs=LocalFindIDsToShow(matchingIDs,this.ParentHash);
        filtitems=LocalGetFilteredSignals(this.Items,treeIDs);
    else

        matchingIDs=1:numel(itemnames);
        treeIDs=matchingIDs;
        filtitems=this.Items;
    end
end

function ids2show=LocalFindIDsToShow(matchingIDs,parenthash)
    ids2show=[];
    if isempty(parenthash)
        return;
    end
    for ct=1:numel(matchingIDs)
        parentIDs=parenthash{matchingIDs(ct)};
        ids2show=[ids2show,parentIDs];
    end
    ids2show=unique(ids2show);
end

function filtitems=LocalGetFilteredSignals(items,treeids)
    filtitems=[];
    for ct=1:numel(items)
        if strcmp(class(items{ct}),'Simulink.sigselector.SignalItem')

            if any(items{ct}.TreeID==treeids)
                filtitems{end+1}=items{ct};
            end
        else

            busitem=[];
            hierind=1;
            for ctb=1:numel(items{ct}.Hierarchy)
                if any(items{ct}.Hierarchy(ctb).TreeID==treeids)
                    busitem.Hierarchy(hierind)=LocalFilterBus(items{ct}.Hierarchy(ctb),treeids);
                    hierind=hierind+1;
                end
            end
            if~isempty(busitem)
                filtitems{end+1}=items{ct};
                filtitems{end}.Hierarchy=busitem.Hierarchy;
            end
        end
    end
end
function filthier=LocalFilterBus(bushier,ids)
    filthier=[];
    if any(bushier.TreeID==ids)
        filthier.SignalName=bushier.SignalName;
        filthier.BusObject=bushier.BusObject;
        filthier.TreeID=bushier.TreeID;
        filthier.Icon=bushier.Icon;
        if isempty(bushier.Children)
            filthier.Children=[];
        else
            childind=1;
            for ct=1:numel(bushier.Children)
                childhier=LocalFilterBus(bushier.Children(ct),ids);
                if~isempty(childhier)
                    filthier.Children(childind)=childhier;
                    childind=childind+1;
                end
            end


            if childind==1
                filthier.Children=[];
            end
        end
    end
end






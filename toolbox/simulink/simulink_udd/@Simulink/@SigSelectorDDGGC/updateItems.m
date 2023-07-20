function updateItems(this,hidebusroot,es)








    [this.DDGItems,this.DDGIDs,this.DDGSelectionPaths]=...
    LocalGetAllItemsAndIDs(es.getRawItems(),hidebusroot);
end







function[items,ids,selpaths]=LocalGetAllItemsAndIDs(cursig,hidebusroot)
    items={};
    ids={};
    selpaths={};
    for ct=1:numel(cursig)
        if strcmp(class(cursig{ct}),'Simulink.sigselector.BusItem')





            hier=cursig{ct}.Hierarchy;

            if~hidebusroot
                items=[items,{cursig{ct}.Name}];
                ids=[ids,{hier.TreeID}];
                selpaths{end+1}=LocalDDGFormat(cursig{ct}.Name);

                [itemsinbus,idsinbus]=LocalGetBusItemsAndIDs(hier.Children);
                selpathsinbus=LocalGetBusSelPaths({},{cursig{ct}.Name},hier.Children);

                items=[items,{itemsinbus}];
                ids=[ids,{idsinbus}];
                selpaths=[selpaths,selpathsinbus];
            else

                [items,ids]=LocalGetBusItemsAndIDs(hier);
                selpaths=LocalGetBusSelPaths({},{},hier);
            end
        else

            items=[items,{cursig{ct}.Name}];
            ids=[ids,{cursig{ct}.TreeID}];
            selpaths{end+1}=LocalDDGFormat(cursig{ct}.Name);
        end
    end
end

function[ddgselectionpaths]=LocalGetBusSelPaths(ddgselectionpaths,curloc,bushier)
    for ct=1:numel(bushier)
        str=bushier(ct).SignalName;
        if isempty(curloc)
            ddgselectionpaths{end+1}=LocalDDGFormat(str);
        else
            ddgselectionpaths{end+1}=[LocalFlatCurrentLocation(curloc),'/',LocalDDGFormat(str)];
        end
        if~isempty(bushier(ct).Children)

            curloc{end+1}=str;

            [ddgselectionpaths]=LocalGetBusSelPaths(ddgselectionpaths,curloc,bushier(ct).Children);

            curloc(end)=[];
        end
    end
end






function[busitems,busids]=LocalGetBusItemsAndIDs(busstruct)
    busitems={};
    busids={};
    s=busstruct;
    for ct=1:numel(s)
        if isempty(s(ct).Children)

            busitems=[busitems,{s(ct).SignalName}];
            busids=[busids,{s(ct).TreeID}];
        else

            [itms,ids]=LocalGetBusItemsAndIDs(s(ct).Children);
            busitems=[busitems,{s(ct).SignalName,itms}];
            busids=[busids,{s(ct).TreeID,ids}];
        end
    end
end





function str=LocalFlatCurrentLocation(curloc)
    str=LocalDDGFormat(curloc{1});
    for ct=2:numel(curloc)
        str=[str,'/',LocalDDGFormat(curloc{ct})];
    end

end





function out=LocalDDGFormat(str)
    out=regexprep(str,{'/'},{'//'});
end





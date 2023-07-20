function[treeitems,treename,listname,listitems]=constructTreeItems(this)











    tc=this.TCPeer;
    filter=tc.getFilterText();


    opts=tc.getOptions();
    name=opts.RootName;
    if~isempty(filter)
        treename=[name,' ',DAStudio.message('Simulink:sigselector:FilteredTreeTitle')];
        listname=[name,' ',DAStudio.message('Simulink:sigselector:FilteredTreeTitleListView')];
    else
        treename=name;
        listname=name;
    end


    if isempty(filter)

        treeitems=this.DDGItems;
        listitems=tc.FullItemNames;
    else
        [treeitems,listitems]=LocalApplyFilter(tc,this);
    end





    function[filttreeitems,filtlistitems]=LocalApplyFilter(tc,this)

        [matchingIDs,treeIDs]=tc.executeFilter();

        filtlistitems=tc.FullItemNames(matchingIDs);

        filttreeitems=LocalGetFilteredItems(this.DDGItems,this.DDGIDs,treeIDs);





        function filtitems=LocalGetFilteredItems(allitems,allids,ids2show)
            filtitems={};
            num_items=numel(allitems);


            for ct=1:num_items
                if ischar(allitems{ct})

                    thisid=allids{ct};

                    if any(thisid==ids2show)

                        filtitems=[filtitems,allitems(ct)];

                        if(ct~=num_items)&&iscell(allitems{ct+1})

                            filtitemsinbus=LocalGetFilteredItems(allitems{ct+1},allids{ct+1},ids2show);

                            if~isempty(filtitemsinbus)
                                filtitems=[filtitems,{filtitemsinbus}];
                            end
                        end
                    else

                        continue;
                    end
                end
            end




















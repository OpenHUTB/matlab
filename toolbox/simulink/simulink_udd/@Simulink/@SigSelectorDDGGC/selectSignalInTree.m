function selectSignalInTree(this,dialog)









    tc=this.TCPeer;
    opts=tc.getOptions;
    multiselect=opts.TreeMultipleSelection;
    istreevisible=~opts.FilterVisible||isempty(tc.getFilterText)||~tc.getFlatList;
    if istreevisible

        selections=dialog.getWidgetValue('sigselector_signalsTree');
        try
            selectedids=LocalFindSelectedIDs(selections,this.DDGSelectionPaths,multiselect);
        catch %#ok<CTCH>





            return;
        end



        dialog.setWidgetValue('sigselector_signalsList',[]);
        dialog.setWidgetValue('sigselector_signalsList',...
        LocalGetSelectedListIndex(tc.FullItemNames,selectedids,dialog));
    else

        return;
    end


    this.TCPeer.applyTreeSelections(selectedids);

    evdata=Simulink.SigSelectorDDGSelectEvent(this,'TreeChangeEvent',dialog,this.TCPeer);
    send(this,'TreeChangeEvent',evdata);







    function ids=LocalFindSelectedIDs(selections,userdata,multiselect)
        if multiselect

            len=numel(selections);
            ids=zeros(len,1);
            for ct=1:len
                ids(ct)=find(strcmp(selections{ct},userdata));
            end
        else

            ids=find(strcmp(selections,userdata));
        end
        function val=LocalGetSelectedListIndex(fullnames,ids,dialog)
            listitems=dialog.getUserData('sigselector_signalsList');
            val=[];
            if isempty(ids)
                return;
            else
                for ct=1:numel(ids)
                    ind=find(strcmp(fullnames{ids(ct)},listitems));
                    if~isempty(ind)
                        val(end+1)=ind-1;%#ok<AGROW> % zero-based index
                    end
                end
            end







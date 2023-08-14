function selectSignalInList(this,dialog)









    tc=this.TCPeer;
    opts=tc.getOptions;
    multiselect=opts.TreeMultipleSelection;
    istreevisible=~opts.FilterVisible||isempty(tc.getFilterText)||~tc.getFlatList;
    if istreevisible

        return;
    else

        selections=dialog.getWidgetValue('sigselector_signalsList');
        entries=dialog.getUserData('sigselector_signalsList');
        selectedids=LocalFindSelectedIDs(entries(selections+1),tc.FullItemNames,multiselect);


        this.TCPeer.applyTreeSelections(selectedids);

        evdata=Simulink.SigSelectorDDGSelectEvent(this,'TreeChangeEvent',dialog,tc);
        send(this,'TreeChangeEvent',evdata);
    end








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







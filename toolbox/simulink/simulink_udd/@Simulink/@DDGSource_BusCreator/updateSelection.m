function updateSelection(this,dlg,sigselectorddg)





    filterEmpty=isempty(dlg.getWidgetValue('sigselector_filterEdit'));

    this.unhilite(dlg,false);
    if~(sigselectorddg.TCPeer.isAnyTreeSelection)
        dlg.setEnabled('findButton',0);
        dlg.setEnabled('removeButton',0);
        dlg.setEnabled('upButton',0);
        dlg.setEnabled('downButton',0);
        dlg.setEnabled('addButton',1);
    else
        dlg.setEnabled('findButton',1);
        dlg.setEnabled('addButton',1);
        t=sigselectorddg.TCPeer;
        strings=t.FullItemNames(t.SelectedIDs);
        if isempty(strfind(cell2mat(strings),'.'))
            sigs=dlg.getUserData('signalsList');
            if length(strings)==length(sigs)
                dlg.setEnabled('removeButton',0);
            else
                dlg.setEnabled('removeButton',1);
            end
            for i=1:length(strings)
                if strcmp(strings{i},sigs{end})
                    dlg.setEnabled('downButton',0);
                    break;
                else
                    dlg.setEnabled('downButton',1);
                end
            end
            sortedIds=sort(t.SelectedIDs);
            if(sortedIds(1)>1)
                dlg.setEnabled('upButton',1);
            else
                dlg.setEnabled('upButton',0);
            end

            sortedStrings=t.FullItemNames(sortedIds);
            if length(sortedStrings)>1
                for j=1:length(sigs)
                    if strcmp(sortedStrings{1},sigs{j})
                        count=j;
                        for k=2:length(sortedStrings)
                            count=count+1;
                            if~strcmp(sortedStrings{k},sigs{count})

                                dlg.setEnabled('upButton',0);
                                dlg.setEnabled('downButton',0);
                                dlg.setEnabled('addButton',0);
                                break;
                            end
                        end
                        break;
                    end
                end
            end
        else
            dlg.setEnabled('addButton',0);
            dlg.setEnabled('removeButton',0);
            dlg.setEnabled('upButton',0);
            dlg.setEnabled('downButton',0);
        end


    end

    if~filterEmpty
        dlg.setEnabled('addButton',0);
        dlg.setEnabled('removeButton',0);
        dlg.setEnabled('upButton',0);
        dlg.setEnabled('downButton',0);
    end

end

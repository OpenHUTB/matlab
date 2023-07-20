function setUpDownRenameWidgetStatus(this,dlg,tag)




    [ind,entries]=this.retrieveSelection(dlg);
    visible=dlg.isVisible(tag);

    contiguous=true;
    empty=isempty(ind);
    if length(ind)>1
        delta=ind(2:end)-ind(1:end-1);
        contiguous=isempty(find(delta~=1,1));
    end

    if~empty
        block=this.getBlock.Handle;
        ports=get_param(block,'PortHandles');
        for i=1:length(ind)
            if ind(i)>length(ports.Inport)
                dlg.setEnabled('findButton',0);
            else
                dlg.setEnabled('findButton',0);
                for j=1:length(ports.Inport)
                    name=get_param(ports.Inport(j),'Name');
                    if strcmp(name,entries{ind(i)})
                        dlg.setEnabled('findButton',1);
                        break;
                    end
                end
            end
        end
    end
    filterEmpty=isempty(dlg.getWidgetValue('sigselector_filterEdit'));
    if~filterEmpty
        dlg.setEnabled('upButton',0);
        dlg.setEnabled('downButton',0);
        dlg.setEnabled('addButton',0);
        dlg.setEnabled('removeButton',0)
    elseif~contiguous||empty
        dlg.setEnabled('upButton',0);
        dlg.setEnabled('downButton',0);
        dlg.setEnabled('removeButton',0);
    elseif contiguous&&~empty&&length(entries)>1&&ind(1)==1
        dlg.setEnabled('upButton',0);
        dlg.setEnabled('downButton',1);
        dlg.setEnabled('addButton',1);
        dlg.setEnabled('removeButton',1);
    elseif contiguous&&~empty&&length(entries)>1&&...
        (ind(end)==length(entries))
        dlg.setEnabled('upButton',1);
        dlg.setEnabled('downButton',0);
        dlg.setEnabled('addButton',1);
        dlg.setEnabled('removeButton',1)
    elseif contiguous&&~empty&&length(entries)>1
        dlg.setEnabled('upButton',1);
        dlg.setEnabled('downButton',1);
        dlg.setEnabled('addButton',1);
        dlg.setEnabled('removeButton',1)
    else
        dlg.setEnabled('upButton',0);
        dlg.setEnabled('downButton',0);
        dlg.setEnabled('addButton',1);
        dlg.setEnabled('removeButton',0)
    end

    if~visible||isempty(ind)||length(ind)>1
        dlg.setEnabled('renameEdit',0);
        if~strcmp(dlg.getWidgetValue('renameEdit'),'')
            dlg.setWidgetValue('renameEdit','');
        end
    else
        if(~isempty(dlg.getWidgetValue('signalsList')))
            dlg.setEnabled('renameEdit',1);
            dlg.setWidgetValue('renameEdit',entries{ind});
        end
    end

end

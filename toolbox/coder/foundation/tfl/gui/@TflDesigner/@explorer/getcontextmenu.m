function m=getcontextmenu(handle,selectedNode,otherNodes)





    am=DAStudio.ActionManager;
    m=am.createPopupMenu(handle);
    actions=selectedNode.getcontextactions;

    for idx=1:length(actions)
        if strcmpi(actions{idx},'SEPARATOR')==1
            m.addSeparator;
            continue;
        end
        if strcmpi(actions{idx},'ADD_ENTRY')==1
            k=createmenu_entrytypes(handle);
            m.addSubMenu(k,DAStudio.message('RTW:tfldesigner:FileNewEntry'));
            continue;
        end
        action=handle.getaction(actions{idx});
        tmpaction=action;
        if~isempty(strfind(action.Text,'%s'))
            tmpaction=action.copy;

            if isempty(otherNodes)
                tmpaction.Text=sprintf(action.Text,selectedNode.name);
                tmpaction.ToolTip=sprintf(action.ToolTip,selectedNode.name);
                tmpaction.StatusTip=sprintf(action.StatusTip,selectedNode.name);
            else
                tmpaction.Text=strrep(sprintf(action.Text,''),'  ',' ');
                tmpaction.ToolTip=strrep(sprintf(action.ToolTip,''),'  ',' ');
                tmpaction.StatusTip=strrep(sprintf(action.StatusTip,''),'  ',' ');
            end
        end

        m.addMenuItem(tmpaction);
    end
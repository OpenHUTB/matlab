function[dfile,dpath,label,me]=getSelection()




    dfile='';
    dpath='';
    label='ERROR: not open';

    me=rmide.getDAexplr();
    if isempty(me)
        return;
    else
        label='';
    end
    imme=DAStudio.imExplorer;
    imme.setHandle(me);

    treeNode=imme.getCurrentTreeNode();
    treeNodeClass=treeNode.getDisplayClass;
    selection=imme.getSelectedListNodes();
    totalSelected=length(selection);
    if strcmp(treeNodeClass,'Simulink.DataDictionaryScopeNode')

        if totalSelected==0
            label='ERROR: nothing selected';
        elseif totalSelected>1
            label='ERROR: multiple selection not supported';
        else
            [dfile,dpath,label]=rmide.resolveEntry(selection);
        end
    elseif treeNode.rmiIsSupported
        selection=imme.getSelectedListNodes();
        if isempty(selection)
            dfile=treeNode;
        elseif totalSelected>1
            label='ERROR: multiple selection not supported';
        elseif selection.rmiIsSupported
            dfile=selection;
        else
            label='ERROR: selected item does not support RMI linking';
        end
    else
        label='ERROR: selected node does not support RMI linking';
    end
end


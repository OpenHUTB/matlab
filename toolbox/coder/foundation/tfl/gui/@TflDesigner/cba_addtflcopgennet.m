function cba_addtflcopgennet




    me=TflDesigner.getexplorer;
    rt=me.getRoot;

    currnode=rt.currenttreenode;

    if(rt==currnode)||~ishandle(currnode)||isempty(currnode)...
        ||~strcmpi(currnode.Type,'TflTable')

        me.setStatusMessage(DAStudio.message('RTW:tfldesigner:ErrorNotTflTable'));
        return;
    else

        [path,name,ext]=fileparts(currnode.Name);%#ok

        if strcmpi(name,'HitCache')||...
            strcmpi(name,'MissCache')||...
            strcmpi(ext,'.mat')||...
            strcmpi(ext,'.p')


            me.setStatusMessage(DAStudio.message('RTW:tfldesigner:ErrorEntryNotAllowed'));
            return;
        else

            entry=RTW.TflCOperationEntryGenerator_NetSlope;

            currelem=currnode.addchild(entry,false);
            me.show;
            TflDesigner.setcurrentlistnode(currelem);
        end

    end

    me.setStatusMessage(DAStudio.message('RTW:tfldesigner:ErrorNotTflTable'));


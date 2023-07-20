function cba_createcustomentry(classtype)




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

            entry=eval(classtype);

            currelem=currnode.addchild(entry,false);
            currelem.iscustomtype=true;

            filepath=evalc(['which ',classtype]);

            if~isempty(strfind(filepath,'%'))
                filepath=filepath(1:strfind(filepath,'%')-1);
            end

            currelem.customfilepath=filepath;

            me.show;
            TflDesigner.setcurrentlistnode(currelem);
        end

    end

    me.setStatusMessage(DAStudio.message('RTW:tfldesigner:ReadyStatus'));



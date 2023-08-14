function cba_createcustom(desc)



    me=TflDesigner.getexplorer;
    rt=me.getRoot;

    currnode=rt.currenttreenode;

    if(rt==currnode)||~ishandle(currnode)||isempty(currnode)...
        ||~strcmpi(currnode.Type,'TflTable')

        me.setStatusMessage(DAStudio.message('RTW:tfldesigner:ErrorNotTflTable'));
        return;
    else
        customObj=TflDesigner.customclass;

        if strcmp(desc,'new')
            [~]=DAStudio.Dialog(customObj,'new','DLG_STANDALONE');
        else
            [~]=DAStudio.Dialog(customObj,'open','DLG_STANDALONE');
        end
    end


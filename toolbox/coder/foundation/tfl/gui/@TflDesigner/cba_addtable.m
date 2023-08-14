function cba_addtable



    me=TflDesigner.getexplorer;
    rt=me.getRoot;
    if~rt.iseditorbusy
        rt.iseditorbusy=true;
        newTable=RTW.TflTable;

        currnode=rt.insertnode(newTable);

        rt.firehierarchychanged;
        me.show;

        TflDesigner.setcurrenttreenode(currnode);

        me.updateactions;
        me.setStatusMessage(DAStudio.message('RTW:tfldesigner:ReadyStatus'));
        rt.iseditorbusy=false;
    end




function bLoaded=loadObject(h)




    assert(~h.isLoaded);
    bLoaded=false;



    me=SigLogSelector.getExplorer;
    me.getRoot.skipAllPropChangeEvents=true;
    try
        load_system(h.Name);
        me.getRoot.skipAllPropChangeEvents=false;
    catch e
        me.getRoot.skipAllPropChangeEvents=false;
        SigLogSelector.displayWarningDlg(e.identifier,e.message);
        return;
    end


    h.daobject=get_param(h.Name,'Object');


    h.addListeners;
    h.daobject.registerDAListeners;


    h.populate;


    bLoaded=true;
    h.fireHierarchyChanged;

end


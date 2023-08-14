function result=registerDomain()








    result=[];
    if rmi.loadLinktype('oslc.linktype_rmi_oslc')
        rmipref('SelectionLinkDoors',true);
        rmi.menus_selection_links([]);
        rmiml.selectionLink([]);
        result=rmi.linktype_mgr('resolveByRegName','linktype_rmi_oslc');
    end
end

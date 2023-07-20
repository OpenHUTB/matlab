function hid=getCurrentHID()







    hid=GLUE2.HierarchyId.empty();
    studio=DAS.Studio.getAllStudiosSortedByMostRecentlyActive();
    if~isempty(studio)
        editor=getActiveEditor(studio(1).App);
        hid=getHierarchyId(editor);
    end
end

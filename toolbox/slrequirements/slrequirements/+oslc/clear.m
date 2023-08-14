function clear()











    oslc.connection([]);
    oslc.server([]);
    oslc.user([]);

    oslc.Requirement.registry('_clear_');
    oslc.Project.registry('_clear_');
    oslc.Project.currentProject('','');
    oslc.manualSelectionLink();
    oslc.selection('','');

end

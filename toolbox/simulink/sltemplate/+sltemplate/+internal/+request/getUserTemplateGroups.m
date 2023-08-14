
function groups=getUserTemplateGroups
    [~,templates]=Simulink.findTemplates('*');
    templates=[templates{:}];
    groups=unique({templates.Group})';
    groups=groups(~cellfun(@sltemplate.internal.utils.isInBuiltinGroup,groups));
end
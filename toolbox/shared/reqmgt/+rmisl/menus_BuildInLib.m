function schema=menus_BuildInLib(varargin)

    schema=DAStudio.ActionSchema;
    schema.label=getString(message('Slvnv:reqmgt:BuiltInLibNoRMI'));
    schema.tag='Simulink:RequirementsMenuForBuiltInLib';
    schema.state='Disabled';
end
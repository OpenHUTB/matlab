function schema=simscapeMenu(cbInfo)




    schema=sl_container_schema;
    schema.label='&Simscape';
    schema.tag='Simulink:SimscapeMenu';
    schema.state='Enabled';
    schema.autoDisableWhen='Busy';
    im=DAStudio.InterfaceManagerHelper(cbInfo.studio,'Simulink');
    children={...
    im.getAction('SimscapeMenu:Statistics'),...
    im.getAction('SimscapeMenu:VariableViewer')...
    };
    schema.childrenFcns=children;

end

function schema=CodeMenu(fncname,cbinfo)

    fnc=str2func(fncname);

    if nargout(fnc)
        schema=fnc(cbinfo);
    else
        schema=[];
        fnc(cbinfo);
    end
end

function schema=DataObjectsMenu(cbinfo)
    schema=sl_container_schema;
    schema.tag='Simulink:DataObjectsMenu';
    schema.label=DAStudio.message('Simulink:studio:DataObjectsMenu');

    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    schema.childrenFcns={im.getAction('Simulink:DataClassDesigner'),...
    im.getAction('Simulink:DataObjectWizard'),...
    im.getAction('Simulink:CustomStorageClassDesigner')
    };

    schema.autoDisableWhen='Busy';
end

function state=loc_getDataClassDesignerState(~)
    state='Enabled';
end

function schema=DataClassDesigner(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:DataClassDesigner';
    schema.label=DAStudio.message('Simulink:studio:DataClassDesigner');
    schema.state=loc_getDataClassDesignerState(cbinfo);
    schema.callback=@DataClassDesignerCB;

    schema.autoDisableWhen='Busy';
end

function DataClassDesignerCB(~)
    sldataclassdesigner('LaunchFromToolsMenu');
end

function schema=CustomStorageClassDesigner(~)
    schema=sl_action_schema;
    schema.tag='Simulink:CustomStorageClassDesigner';
    schema.label=DAStudio.message('Simulink:studio:CustomStorageClassDesigner');
    schema.callback=@CustomStorageClassDesignerCB;

    schema.autoDisableWhen='Busy';
end

function CustomStorageClassDesignerCB(~)
    cscdesigner;
end


function schema=DataObjectWizard(~)
    schema=sl_action_schema;
    schema.tag='Simulink:DataObjectWizard';
    schema.label=DAStudio.message('Simulink:General:DataObjectWizard');
    schema.statustip=DAStudio.message('Simulink:General:DataObjectWizardTip');
    schema.callback=@DataObjectWizardCB;
end

function DataObjectWizardCB(cbinfo)
    dataobjectwizard(cbinfo.model.Name);
end



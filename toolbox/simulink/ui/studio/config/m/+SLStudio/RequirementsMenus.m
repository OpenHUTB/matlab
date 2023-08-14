function schema=RequirementsMenus(fncname,cbinfo)




    fcn=str2func(fncname);
    schema=fcn(cbinfo);
end

function schema=BlockRequirementsMenu(cbinfo)%#ok<*DEFNU>
    schema=DAStudio.ContainerSchema;
    schema.tag='Simulink:BlockRequirementsMenu';
    if strcmp(cbinfo.menuType,'MenuBar')
        schema.label=DAStudio.message('Simulink:studio:SelectedObjectRequirementsMenu');
    else
        schema.label=DAStudio.message('Simulink:studio:BlockRequirementsMenu');
    end
    if~rmi_exists||SLStudio.Utils.isInterfaceViewActive(cbinfo)
        schema.state='Hidden';
        schema.childrenFcns={DAStudio.Actions('HiddenSchema')};
    else
        schema.state=rmisl.reqMenuState(cbinfo,false);
        schema.userdata=false;
        schema.generateFcn=@rmisl.menus_rmi_object;
    end

    schema.autoDisableWhen='Busy';
end

function schema=VectorRequirementsMenu(cbinfo)
    schema=DAStudio.ContainerSchema;
    schema.tag='Simulink:VectorRequirementsMenu';
    schema.label=DAStudio.message('Simulink:studio:VectorRequirementsMenu');
    if~rmi_exists||SLStudio.Utils.isInterfaceViewActive(cbinfo)
        schema.state='Hidden';
        schema.childrenFcns={DAStudio.Actions('HiddenSchema')};
    else
        schema.state=rmisl.reqMenuState(cbinfo,false);
        schema.generateFcn=@rmisl.menus_rmi_vector;
    end

    schema.autoDisableWhen='Busy';
end

function schema=SysRequirementsMenu(cbinfo)
    schema=DAStudio.ContainerSchema;
    schema.tag='Simulink:SysRequirementsMenu';
    schema.label=DAStudio.message('Simulink:studio:SysRequirementsMenu');
    if~rmi_exists||SLStudio.Utils.isInterfaceViewActive(cbinfo)
        schema.state='Hidden';
        schema.childrenFcns={DAStudio.Actions('HiddenSchema')};
    else
        schema.state=rmisl.reqMenuState(cbinfo,true);
        schema.userdata=true;
        schema.generateFcn=@rmisl.menus_rmi_object;
    end

    schema.autoDisableWhen='Busy';
end

function schema=AnalysisRequirementsMenu(cbinfo)
    schema=DAStudio.ContainerSchema;
    schema.tag='Simulink:AnalysisRequirementsMenu';
    schema.label=DAStudio.message('Simulink:studio:AnalysisRequirementsMenu');
    if~rmi_exists||SLStudio.Utils.isInterfaceViewActive(cbinfo)
        schema.state='Hidden';
        schema.childrenFcns={DAStudio.Actions('HiddenSchema')};
    else
        schema.generateFcn=@rmisl.menus_rmi_tools;
    end

    schema.autoDisableWhen='Busy';
end

function schema=AnnotationRequirementsMenu(cbinfo)
    schema=DAStudio.ContainerSchema;
    schema.tag='Simulink:AnnotationRequirementsMenu';
    schema.label=DAStudio.message('Simulink:studio:BlockRequirementsMenu');
    if~rmi_exists||SLStudio.Utils.isInterfaceViewActive(cbinfo)
        schema.state='Hidden';
        schema.childrenFcns={DAStudio.Actions('HiddenSchema')};
    else
        schema.state=rmisl.annotationMenuState(cbinfo);
        if strcmp(schema.state,'Hidden')
            schema.childrenFcns={DAStudio.Actions('HiddenSchema')};
        else
            schema.generateFcn=@rmisl.menus_rmi_annotation;
        end
    end
    schema.autoDisableWhen='Busy';
end

function out=rmi_exists()
    persistent rmiExists;
    if isempty(rmiExists)
        rmiExists=(exist([matlabroot,'/toolbox/shared/reqmgt'],'dir')==7);
    end
    out=rmiExists;
end



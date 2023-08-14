function schema=NewMenu(fcnName,cbinfo)




    im=DAStudio.IconManager;
    if~im.hasIcon('Simulink:New')
        im.addFileToIcon('Simulink:New',[(matlabroot),'/toolbox/shared/dastudio/resources/glue/Toolbars/24px/New_24.png'],24);
        im.addFileToIcon('Simulink:New',[(matlabroot),'/toolbox/shared/dastudio/resources/glue/Toolbars/16px/NewModel_16.png'],16);
        im.addFileToIcon('Simulink:NewModel',[(matlabroot),'/toolbox/shared/dastudio/resources/glue/Toolbars/24px/NewModel_24.png'],24);
        im.addFileToIcon('Simulink:NewModel',[(matlabroot),'/toolbox/shared/dastudio/resources/glue/Toolbars/16px/NewModel_16.png'],16);
        im.addFileToIcon('Simulink:NewReferenceableSubsystem',[(matlabroot),'/toolbox/shared/dastudio/resources/glue/Toolbars/24px/NewReferenceableSubsystem_24.png'],24);
        im.addFileToIcon('Simulink:NewReferenceableSubsystem',[(matlabroot),'/toolbox/shared/dastudio/resources/glue/Toolbars/16px/NewReferenceableSubsystem_16.png'],16);
        im.addFileToIcon('Simulink:NewLibrary',[(matlabroot),'/toolbox/shared/dastudio/resources/glue/Toolbars/24px/NewLibrary_24.png'],24);
        im.addFileToIcon('Simulink:NewLibrary',[(matlabroot),'/toolbox/shared/dastudio/resources/glue/Toolbars/16px/NewLibrary_16.png'],16);
        im.addFileToIcon('Simulink:NewChart',[(matlabroot),'/toolbox/shared/dastudio/resources/glue/Toolbars/24px/NewChart_24.png'],24);
        im.addFileToIcon('Simulink:NewChart',[(matlabroot),'/toolbox/shared/dastudio/resources/glue/Toolbars/16px/NewChart_16.png'],16);
        im.addFileToIcon('Simulink:NewAppChart',[(matlabroot),'/toolbox/shared/dastudio/resources/glue/Toolbars/24px/NewAppChart_24.png'],24);
        im.addFileToIcon('Simulink:NewAppChart',[(matlabroot),'/toolbox/shared/dastudio/resources/glue/Toolbars/16px/NewAppChart_16.png'],16);
        im.addFileToIcon('Simulink:NewProject',[(matlabroot),'/toolbox/shared/dastudio/resources/glue/Toolbars/24px/NewSimulinkProject_24.png'],24);
        im.addFileToIcon('Simulink:NewProject',[(matlabroot),'/toolbox/shared/dastudio/resources/glue/Toolbars/16px/NewSimulinkProject_16.png'],16);
        im.addFileToIcon('Simulink:NewArchitecture',[(matlabroot),'/toolbox/shared/dastudio/resources/glue/Toolbars/24px/NewArchitecture_24.png'],24);
        im.addFileToIcon('Simulink:NewArchitecture',[(matlabroot),'/toolbox/shared/dastudio/resources/glue/Toolbars/16px/NewArchitecture_16.png'],16);
    end

    fcn=str2func(fcnName);
    if nargout(fcn)
        schema=fcn(cbinfo);
    else
        schema=[];
        fcn(cbinfo);
    end
end

function schema=FileMenuNewSubMenu(~)
    schema=sl_container_schema;
    schema.tag='Simulink:NewMenu';
    schema.label=DAStudio.message('Simulink:studio:NewMenu');
    schema.childrenFcns=GetNewMenuChildren;
    schema.autoDisableWhen='Never';
end

function fcns=GetNewMenuChildren(~)
    fcns={...
    @NewDefaultModel,...
    @NewDefaultReferenceableSubsystem,...
    'separator',...
    @NewModel,...
    @NewReferenceableSubsystem,...
    @NewChart,...
    @NewLibrary,...
    @NewProject
    };
    fcns=[fcns,{
    'separator',...
    @NewArchitecture}];
end

function[schema,ti]=NewDefaultModel(~)
    schema=sl_action_schema;
    schema.tag='Simulink:NewDefaultModel';

    ti=[];
    try %#ok<TRYNC>
        dmt=Simulink.defaultModelTemplate();
        if~isempty(dmt)
            ti=sltemplate.TemplateInfo(dmt);
        end
    end

    if~isempty(ti)
        schema.label=ti.Title;
        schema.tooltip=ti.Description;
    else




        schema.label=DAStudio.message('simulink_core_templates:factory_default_model:Title');
        schema.tooltip=DAStudio.message('simulink_core_templates:factory_default_model:Description');
    end

    schema.icon='Simulink:NewModel';
    schema.accelerator='Ctrl+N';
    schema.autoDisableWhen='Never';

    schema.callback=@(~)SLStudio.Utils.createNewDefaultModel();
end

function schema=NewDefaultModelForToolStrip(cbinfo)
    [schema,blankModelInfo]=NewDefaultModel(cbinfo);
    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon='model';

        if isempty(blankModelInfo)
            schema.label=DAStudio.message('simulink_ui:studio:resources:blankModelActionLabel');
            schema.tooltip=DAStudio.message('simulink_ui:studio:resources:CreateNewBlankModelActionDescription');
        end
    end
end

function schema=NewDefaultReferenceableSubsystem(~)
    schema=sl_action_schema;
    schema.label=DAStudio.message('Simulink:studio:NewReferenceableSubsystem');
    schema.tooltip=DAStudio.message('Simulink:studio:NewReferenceableSubsystemTooltip');
    schema.icon='Simulink:NewReferenceableSubsystem';
    schema.autoDisableWhen='Never';
    schema.callback=@(~)open_system(new_system('','Subsystem'));
end

function schema=NewModel(~)
    schema=sl_action_schema;
    schema.callback=@(~)sltemplate.ui.StartPage.newSimulinkModelView();
    if sltemplate.internal.utils.isStartPageAvailable
        schema.tag='Simulink:StartPageNewModel';
        schema.label=DAStudio.message('Simulink:studio:StartPageNewModel');
    else
        schema.tag='Simulink:NewModel';
        schema.label=DAStudio.message('Simulink:studio:NewModel');
    end
    schema.tooltip=DAStudio.message('Simulink:studio:NewModelTooltip');
    schema.icon='Simulink:NewModel';
    schema.autoDisableWhen='Never';
end

function schema=NewReferenceableSubsystem(~)
    schema=sl_action_schema;
    schema.callback=@(~)sltemplate.ui.StartPage.newSimulinkSubsystemView();
    if sltemplate.internal.utils.isStartPageAvailable
        schema.tag='Simulink:StartPageNewReferenceableSubsystem';
        schema.label=DAStudio.message('Simulink:studio:StartPageNewReferenceableSubsystem');
    else
        schema.tag='Simulink:NewReferencesableSubsystem';
        schema.label=DAStudio.message('Simulink:studio:NewReferenceableSubsystem');
    end
    schema.tooltip=DAStudio.message('Simulink:studio:StartPageNewReferenceableSubsystemTooltip');
    schema.icon='Simulink:NewReferenceableSubsystem';
    schema.autoDisableWhen='Never';
end

function schema=NewChart(cbinfo)
    schema=sl_action_schema;
    if SFStudio.Utils.isStateflowApp(cbinfo)
        schema.tag='Simulink:NewChart';
        schema.label=DAStudio.message('Simulink:studio:NewChart');
        schema.callback=@(~)Stateflow.App.Studio.CreateNewSFXWithUserName();
        schema.icon='Simulink:NewAppChart';
    elseif sltemplate.internal.utils.isStartPageAvailable
        schema.tag='Simulink:StartPageNewChart';
        schema.label=DAStudio.message('Simulink:studio:StartPageNewChart');
        schema.callback=@(~)sltemplate.ui.StartPage.newStateflowSFView();
        schema.icon='Simulink:NewChart';
    else
        schema.tag='Simulink:NewChart';
        schema.label=DAStudio.message('Simulink:studio:NewChart');
        schema.callback=@(~)sfnew;
        schema.icon='Simulink:NewChart';
    end
    schema.tooltip=DAStudio.message('Simulink:studio:NewChartTooltip');
    schema.autoDisableWhen='Never';
end

function schema=NewLibrary(~)
    schema=sl_action_schema;
    schema.callback=@(~)sltemplate.ui.StartPage.newSimulinkLibraryView();
    if sltemplate.internal.utils.isStartPageAvailable
        schema.tag='Simulink:StartPageNewLibrary';
        schema.label=DAStudio.message('Simulink:studio:StartPageNewLibrary');
    else
        schema.tag='Simulink:NewLibrary';
        schema.label=DAStudio.message('Simulink:studio:NewLibrary');
    end
    schema.tooltip=DAStudio.message('Simulink:studio:NewLibraryTooltip');
    schema.icon='Simulink:NewLibrary';
    schema.autoDisableWhen='Never';
end

function schema=NewProject(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:StartPageNewProject';
    if~isa(cbinfo,'dig.CallbackInfo')||~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon='Simulink:NewProject';
        schema.label=DAStudio.message('Simulink:studio:StartPageNewProject');
    end
    schema.callback=@(~)sltemplate.ui.StartPage.newSimulinkProjectView();
    schema.autoDisableWhen='Never';
    if sltemplate.internal.utils.isStartPageAvailable
        schema.state='Enabled';
    else
        schema.state='Disabled';
    end
end

function schema=NewArchitecture(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:NewArchitecture';
    if~isa(cbinfo,'dig.CallbackInfo')||~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon='Simulink:NewArchitecture';
        schema.tooltip=DAStudio.message('SystemArchitecture:studio:NewArchitectureTooltip');
        schema.label=DAStudio.message('SystemArchitecture:studio:NewArchitecture');
    end

    schema.callback=@(~)sltemplate.ui.StartPage.newArchitectureModelView();
    schema.autoDisableWhen='Never';

    if dig.isProductInstalled('System Composer')
        schema.state='Enabled';
    else
        schema.state='Hidden';
    end
end

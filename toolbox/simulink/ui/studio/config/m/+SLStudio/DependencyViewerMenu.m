function schema=DependencyViewerMenu(fncname,cbinfo)



    fnc=str2func(fncname);

    if nargout(fnc)
        schema=fnc(cbinfo);
    else
        schema=[];
        if nargin==3
            fnc(cbinfo,eventData);
        else
            fnc(cbinfo);
        end
    end
end

function schema=DependencyViewerMenuImpl(cbinfo)%#ok<*DEFNU> % ( menu, cbinfo )
    schema=sl_container_schema;
    schema.label=DAStudio.message('Simulink:studio:DependencyViewerMenu');

    menu=cbinfo.userdata;
    schema.tag=['Simulink:',menu,'_DependencyViewerMenu'];


    children={{@DependencyIncludingLibraries,menu},...
    {@DependencyExcludingLibraries,menu}...
    ,'separator',...
    {@DependencyReferenced,menu}
    };

    schema.childrenFcns=children;

    schema.autoDisableWhen='Busy';
end

function schema=DependencyIncludingLibraries(cbinfo)
    schema=sl_action_schema;
    menu=cbinfo.userdata;
    schema.tag=['Simulink:',menu,'_DependencyIncludingLibraries'];
    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon='modelDependencies';
    else
        schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:DependencyIncludingLibraries');
    end
    schema.obsoleteTags={'Simulink:DependencyViewer:MDLFilesIncludingLibraries'};
    schema.callback=@DependencyIncludingLibrariesCB;

    schema.autoDisableWhen='Busy';
end

function DependencyIncludingLibrariesCB(cbinfo)
    depview(cbinfo.model.Name,'FileDependenciesIncludingLibraries',true);
end

function schema=DependencyExcludingLibraries(cbinfo)
    schema=sl_action_schema;
    menu=cbinfo.userdata;
    schema.tag=['Simulink:',menu,'_DependencyExcludingLibraries'];
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:DependencyExcludingLibraries');
    schema.obsoleteTags={'Simulink:DependencyViewer:MDLFilesExcludingLibraries'};
    schema.callback=@DependencyExcludingLibrariesCB;

    schema.autoDisableWhen='Busy';
end

function DependencyExcludingLibrariesCB(cbinfo)
    depview(cbinfo.model.Name,'FileDependenciesExcludingLibraries',true);
end

function schema=DependencyReferenced(cbinfo)
    schema=sl_action_schema;
    menu=cbinfo.userdata;
    schema.tag=['Simulink:',menu,'_DependencyReferenced'];
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:DependencyReferenced');
    schema.obsoleteTags={'Simulink:DependencyViewer:Referenced Model Instances'};
    schema.callback=@DependencyReferencedCB;

    schema.autoDisableWhen='Busy';
end

function DependencyReferencedCB(cbinfo)
    SLStudio.internal.ScopedStudioBlocker();
    depview(SLStudio.Utils.getTopLevelModelName(cbinfo),'ModelReferenceInstance',true);
end



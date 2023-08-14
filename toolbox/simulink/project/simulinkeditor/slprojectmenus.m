function schema=slprojectmenus(fncname,cbinfo,eventData)




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

function schema=ProjectCheckout(cbinfo)
    import com.mathworks.toolbox.slproject.project.GUI.explorer.extensions.providers.ConfigurationManagement.ConcreteActions.CMActionProviderCheckout;

    schema=sl_action_schema;
    schema.tag='Simulink:ProjectCheckout';
    schema.label=SLStudio.Utils.getMessage(cbinfo,'SimulinkProject:menu:checkout');
    schema.userdata=schema.tag;
    schema.autoDisableWhen='Busy';

    if matlab.internal.project.util.useWebFrontEnd()
        schema.state='Disabled';
        return;
    end

    [fileToProjectMapper,fileToCMCacheMapper]=i_getFileMaps(cbinfo);

    schema.callback=@(x)fileToCMCacheMapper.checkout();

    if fileToProjectMapper.InALoadedProject...
        &&fileToCMCacheMapper.UsingSourceControl...
        &&fileToCMCacheMapper.CanCheckOut...
        &&~fileToCMCacheMapper.IsCheckedOut...
        &&CMActionProviderCheckout.validStatusForOperation(fileToCMCacheMapper.Status)

        schema.state='Enabled';
    else
        schema.state='Disabled';
    end

end

function schema=ProjectUnCheckout(cbinfo)
    import com.mathworks.toolbox.slproject.project.GUI.explorer.extensions.providers.ConfigurationManagement.ConcreteActions.CMActionProviderUncheckout;

    schema=sl_action_schema;
    schema.tag='Simulink:ProjectUnCheckOut';
    schema.label=SLStudio.Utils.getMessage(cbinfo,'SimulinkProject:menu:unCheckout');
    schema.userdata=schema.tag;
    schema.autoDisableWhen='Busy';

    if matlab.internal.project.util.useWebFrontEnd()
        schema.state='Disabled';
        return;
    end

    [fileToProjectMapper,fileToCMCacheMapper]=i_getFileMaps(cbinfo);

    schema.callback=@(x)fileToCMCacheMapper.uncheckout();

    if~(fileToProjectMapper.InALoadedProject&&fileToCMCacheMapper.UsingSourceControl)
        schema.state='Disabled';
        return;
    end

    if~isempty(fileToCMCacheMapper.IsCheckedOut)&&fileToCMCacheMapper.IsCheckedOut
        schema.state='Enabled';
        return;
    end

    schema.label=DAStudio.message('SimulinkProject:menu:revertLocal');

    if(CMActionProviderUncheckout.validStatusForOperation(fileToCMCacheMapper.Status))
        schema.state='Enabled';
    else
        schema.state='Disabled';
    end

end

function schema=ProjectCompareToRevision(cbinfo)
    import com.mathworks.toolbox.slproject.project.GUI.explorer.extensions.providers.ConfigurationManagement.ConcreteActions.CMActionProviderDiffToSpecifiedRevision;

    schema=sl_action_schema;
    schema.tag='Simulink:ProjectCompareToRevision';
    schema.label=SLStudio.Utils.getMessage(cbinfo,'SimulinkProject:menu:CompareToRevision');
    schema.userdata=schema.tag;
    schema.autoDisableWhen='Busy';

    if matlab.internal.project.util.useWebFrontEnd()
        schema.state='Disabled';
        return;
    end

    [fileToProjectMapper,fileToCMCacheMapper]=i_getFileMaps(cbinfo);

    schema.callback=@(x)fileToCMCacheMapper.compareToRevision();
    if fileToProjectMapper.InALoadedProject...
        &&fileToCMCacheMapper.UsingSourceControl...
        &&CMActionProviderDiffToSpecifiedRevision.appliesTo(fileToCMCacheMapper.SourceControlCache.getAdapter())...
        &&CMActionProviderDiffToSpecifiedRevision.validStatusForOperation(fileToCMCacheMapper.Status)

        schema.state='Enabled';
    else
        schema.state='Disabled';
    end

end

function schema=ProjectCompareToAncestor(cbinfo)

    schema=sl_action_schema;
    schema.tag='Simulink:ProjectCompareToAncestor';
    schema.label=SLStudio.Utils.getMessage(cbinfo,'SimulinkProject:menu:CompareToAncestor');
    schema.userdata=schema.tag;
    schema.autoDisableWhen='Busy';

    if matlab.internal.project.util.useWebFrontEnd()
        schema.state='Disabled';
        return;
    end

    [fileToProjectMapper,fileToCMCacheMapper]=i_getFileMaps(cbinfo);

    schema.callback=@(x)fileToCMCacheMapper.compareToAncestor();

    import com.mathworks.toolbox.slproject.project.GUI.explorer.extensions.providers.ConfigurationManagement.ConcreteActions.CMActionProviderDiffToCheckedOut;

    if fileToProjectMapper.InALoadedProject...
        &&fileToCMCacheMapper.UsingSourceControl...
        &&CMActionProviderDiffToCheckedOut.appliesTo(fileToCMCacheMapper.SourceControlCache.getAdapter())...
        &&CMActionProviderDiffToCheckedOut.validStatusForOperation(fileToCMCacheMapper.Status)

        schema.state='Enabled';
    else
        schema.state='Disabled';
    end

end

function CreateProjectCB(cbinfo)
    file=cbinfo.model.FileName;
    if isempty(file)||exist(file,"file")==0||cbinfo.model.Dirty=="on"
        msgString=string(message("SimulinkProject:util:DirtyModelError"));
        uiwait(errordlg(msgString,"Error","modal"));
    else
        matlab.internal.project.creation.fromFile(file);
    end
end

function OpenProjectCB(cbinfo)
    context=cbinfo.Context.getProjectContext;
    if context.ProjectOpen
        matlab.project.show();
    else
        openProject(context.ProjectRoot);
    end
end

function OpenProjectRF(cbinfo,action)
    context=cbinfo.Context.getProjectContext;
    if context.ProjectOpen
        action.text=slservices.StringOrID('simulink_ui:studio:resources:ShowProjectForThisModelActionText');
        action.description=slservices.StringOrID('simulink_ui:studio:resources:ShowProjectForThisModelActionDescription');
    else
        action.text=slservices.StringOrID('simulink_ui:studio:resources:OpenProjectForThisModelActionText');
        action.description=slservices.StringOrID('simulink_ui:studio:resources:OpenProjectForThisModelActionDescription');
    end
end

function ShowInProjectCB(cbinfo)
    matlab.internal.project.util.showFilesInProject(currentProject,cbinfo.model.FileName);
end

function FindDependenciesCB(cbinfo)
    matlab.internal.project.dependency.openDependencyAnalyzer(...
    currentProject,...
    "DependenciesOf",cbinfo.model.FileName);
end

function ToggleInProjectCB(cbinfo)
    context=cbinfo.Context.getProjectContext;
    file=get_param(context.ModelHandle,'FileName');

    if matlab.internal.project.util.useWebFrontEnd()
        project=matlab.internal.project.api.makeProjectAvailable(context.ProjectRoot);
        if context.InProject
            project.removeFile(file);
        else
            project.addFile(file);
        end
    else
        if context.InProject
            import com.mathworks.toolbox.slproject.project.GUI.explorer.extensions.providers.project.ConcreteActions.ProjectActionRemove;
            i_runProjectAction(context.ProjectRoot,file,@ProjectActionRemove.remove);
        else
            import com.mathworks.toolbox.slproject.project.GUI.explorer.extensions.providers.project.ConcreteActions.ProjectActionAdd;
            i_runProjectAction(context.ProjectRoot,file,@ProjectActionAdd.add);
        end
    end
end

function ToggleInProjectRF(cbinfo,action)
    context=cbinfo.Context.getProjectContext;
    action.enabled=context.ProjectOpen;
    if context.ProjectOpen&&context.InProject
        action.text=slservices.StringOrID('simulink_ui:studio:resources:RemoveThisModelFromProjectActionText');
        action.description=slservices.StringOrID('simulink_ui:studio:resources:RemoveThisModelFromProjectActionDescription');
        action.icon='removeModelFromProject';
    else
        action.text=slservices.StringOrID('simulink_ui:studio:resources:AddModelToProjectActionText');
        action.description=slservices.StringOrID('simulink_ui:studio:resources:AddModelToProjectActionDescription');
        action.icon='addModelToProject';
    end
end

function i_runProjectAction(projectRoot,file,action)
    import com.mathworks.toolbox.slproject.project.matlab.api.MatlabAPIFacadeFactory;
    pc=MatlabAPIFacadeFactory.getMatchingControlSet(java.io.File(projectRoot));
    if~isempty(pc)
        files=java.util.Arrays.asList(java.io.File(file));
        action(pc,files);
    end
end

function[fileToProjectMapper,fileToCMCacheMapper]=i_getFileMaps(cbinfo)
    fileName=cbinfo.model.FileName;
    fileToProjectMapper=matlab.internal.project.util.FileToProjectMapper(fileName);
    fileToCMCacheMapper=matlab.internal.project.util.FileToCMCacheMapper(fileToProjectMapper);
end

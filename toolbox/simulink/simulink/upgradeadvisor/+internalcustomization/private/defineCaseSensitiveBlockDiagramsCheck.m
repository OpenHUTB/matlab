function defineCaseSensitiveBlockDiagramsCheck()





    check=ModelAdvisor.Check('mathworks.design.CaseSensitiveBlockDiagramNames');
    check.Title=DAStudio.message('SimulinkUpgradeAdvisor:tasks:CaseCheckTitle');
    check.setCallbackFcn(@i_findCaseInsensitiveDependencies,'None','StyleOne');
    check.TitleTips=DAStudio.message('SimulinkUpgradeAdvisor:tasks:CaseCheckDescription');
    check.Visible=true;
    check.Enable=true;
    check.Value=true;
    check.SupportLibrary=true;
    check.CSHParameters.MapKey='ma.simulink';
    check.CSHParameters.TopicID='CaseSensitiveBlockDiagram';


    action=ModelAdvisor.Action;
    action.setCallbackFcn(@i_updateCaseInsensitiveDependencies);
    action.Name=DAStudio.message('SimulinkUpgradeAdvisor:tasks:CaseCheckUpdate');
    action.Description=DAStudio.message('SimulinkUpgradeAdvisor:tasks:CaseCheckUpdateDescription');
    action.Enable=false;
    check.setAction(action);


    modelAdvisor=ModelAdvisor.Root;
    modelAdvisor.register(check);

end


function result=i_findCaseInsensitiveDependencies(model)


    [deps,resolved,updatable]=i_findDependencies(model);
    passed=isempty(deps);

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(model);
    mdladvObj.setCheckResultStatus(passed);
    mdladvObj.setActionEnable(any(updatable));

    if passed
        result=ModelAdvisor.Paragraph(DAStudio.message('SimulinkUpgradeAdvisor:tasks:CaseCheckSuccess'));

    else
        title=ModelAdvisor.Paragraph(DAStudio.message('SimulinkUpgradeAdvisor:tasks:CaseCheckFailure'));

        autoTable=i_createTable(...
        DAStudio.message('SimulinkUpgradeAdvisor:tasks:CaseCheckAutoTable'),...
        deps(updatable),...
        resolved(updatable));

        manualTable=i_createTable(...
        DAStudio.message('SimulinkUpgradeAdvisor:tasks:CaseCheckManualTable'),...
        deps(~updatable),...
        resolved(~updatable));

        result={title,autoTable,manualTable};
    end

end


function table=i_createTable(title,deps,resolved)


    table=ModelAdvisor.FormatTemplate('TableTemplate');
    table.setTableTitle({title});
    table.setColTitles({
    DAStudio.message('SimulinkUpgradeAdvisor:tasks:CaseCheckLocationHeader')
    DAStudio.message('SimulinkUpgradeAdvisor:tasks:CaseCheckReferenceHeader')
    DAStudio.message('SimulinkUpgradeAdvisor:tasks:CaseCheckMatchHeader')
    DAStudio.message('SimulinkUpgradeAdvisor:tasks:CaseCheckTypeHeader')
    });
    table.setSubBar(false);

    [~,idx]=sort([deps.UpstreamComponent]);
    for n=idx
        component=char(deps(n).UpstreamComponent.Path);
        if isempty(component)
            [~,component]=fileparts(deps(n).UpstreamNode.Location{1});
        end
        type=char(deps(n).Type.Base.ID);
        table.addRow({component,deps(n).DownstreamNode.Location{1},resolved{n},type});
    end

end


function result=i_updateCaseInsensitiveDependencies(task)


    state=warning('off');
    cleanup=onCleanup(@()warning(state));

    model=task.MAObj.System;
    file=get_param(model,'FileName');
    [deps,resolved,updatable,saved]=i_findDependencies(model);

    if any(updatable)
        dependencies.internal.action.refactor(deps(updatable),resolved(updatable));
        if saved
            save_system(file);
        end
    end

    result=ModelAdvisor.Paragraph(DAStudio.message('SimulinkUpgradeAdvisor:tasks:CaseCheckUpdateSuccess'));

end


function[deps,resolved,updatable,saved]=i_findDependencies(model)
    file=get_param(model,'FileName');

    saved=~isempty(file);
    if~saved
        file=[tempname,'.slx'];
        slInternal('snapshot_slx',model,file);
        cleanup=onCleanup(@()delete(file));
    end

    [deps,resolved,updatable]=UpgradeAdvisor.internal.findCaseSensitiveDependencies(file);

    if~saved
        [~,tmpModel]=fileparts(file);
        node=dependencies.internal.graph.Node.createFileNode(model);
        deps=dependencies.internal.analysis.simulink.rewriteDependencies(deps,node,tmpModel,model);
    end

end

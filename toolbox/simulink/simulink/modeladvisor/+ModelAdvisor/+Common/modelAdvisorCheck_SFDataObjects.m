








function[bResultStatus,ResultDescription]=modelAdvisorCheck_SFDataObjects(system,xlateTagPrefix)





    ResultDescription={};
    bResultStatus=false;

    Advisor.Utils.LoadLinkCharts(system);


    ft=ModelAdvisor.FormatTemplate('ListTemplate');
    ft.setSubTitle(DAStudio.message([xlateTagPrefix,'SFDataObjectsTitle']));
    ft.setInformation({DAStudio.message([xlateTagPrefix,'SFDataObjectsCheckDesc'])});
    if(strcmp(xlateTagPrefix,'ModelAdvisor:styleguide:'))
        docLinkSfunction{1}={DAStudio.message([xlateTagPrefix,'SFDataObjectsStdRef1'])};
        docLinkSfunction{end+1}={DAStudio.message([xlateTagPrefix,'SFDataObjectsStdRef2'])};
    end


    if strcmp(system,bdroot(system))==false



        failureOutput=ModelAdvisor.Text(...
        DAStudio.message...
        ([xlateTagPrefix,'SFDataObjectsAbnormalContextMsg']));

        ResultDescription{end+1}=ModelAdvisor.LineBreak;
        ResultDescription{end+1}=failureOutput;
    end


    m=get_param(bdroot(system),'Object');
    if~isempty(m)

        dataArray=m.find('-isa','Stateflow.Data');
        machine=m.find('-isa','Stateflow.Machine');
        if~isempty(machine)
            machineId=machine.Id;
        else
            machineId=[];
        end

        chartArray=ModelAdvisor.Common.find_LinkChart(m);
        for i=1:length(chartArray)
            libObj=chartArray(i).getParent;
            if isa(libObj,'Simulink.BlockDiagram')
                libmachine=libObj.find('-isa','Stateflow.Machine');
                if~isempty(libmachine)&&~ismember(libmachine.Id,machineId)
                    dataArray=[dataArray;libObj.find('-isa','Stateflow.Data')];
                    machineId=[machineId;libmachine.Id];
                end
            end
        end
    end

    machineData=[];
    if isempty(machine)==0
        for i=1:length(dataArray)
            scope=dataArray(i).Scope;
            if strcmp(scope,'Local')
                dataId=dataArray(i).Id;
                parentId=sf('ParentOf',dataId);
                if ismember(parentId,machineId)
                    machineData{end+1}=dataArray(i);
                end
            end
        end
    end

    currentResult=[];
    if isempty(machineData)
        ft.setSubResultStatus('Pass');
        if isempty(machine)
            ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'NoChartsFound']));
        else
            ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'SFDataObjectsPassedMsg']));
        end
        ResultDescription{end+1}=ft;
        bResultStatus=true;
    else
        ft.setSubResultStatus('Warn');
        ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'SFDataObjectsFailMsg']));
        ft.setSubBar(0);
        ResultDescription{end+1}=ft;
        ResultDescription{end+1}=ModelAdvisor.LineBreak;
        ResultDescription{end+1}=ModelAdvisor.Text('Use the following links to go to a block or dialog:');
        ResultDescription{end+1}=ModelAdvisor.LineBreak;
        for i=1:length(machineData)
            path=machineData{i}.Path;
            cr=sprintf('\n');
            pathB=strrep(path,cr,'__CR__');
            name=machineData{i}.Name;
            ResultDescription{end+1}=ModelAdvisor.LineBreak;
            ResultDescription{end+1}=['<a href="matlab: styleguideprivate(','''view_data''',',','''',pathB,'''',',','''',name,'''',')">',[path,' : ',name],'</a>'];
        end
        ResultDescription{end+1}=ModelAdvisor.LineBreak;
        ResultDescription{end+1}=ModelAdvisor.LineBreak;
        ResultDescription{end+1}=ModelAdvisor.LineBreak;
        ResultDescription{end+1}=ModelAdvisor.Text(DAStudio.message([xlateTagPrefix,'RecAction']),{'bold'});
        ResultDescription{end+1}=ModelAdvisor.LineBreak;
        ResultDescription{end+1}=ModelAdvisor.Text(DAStudio.message([xlateTagPrefix,'SFDataObjectsRecAction']));
        ResultDescription{end+1}=ModelAdvisor.Text('<hr WIDTH="50%" ALIGN = "left"  SIZE="2"></hr>');
        bResultStatus=false;
    end
end











function[bResultStatus,ResultDescription]=modelAdvisorCheck_SFSignals(system,xlateTagPrefix)


    ResultDescription={};
    bResultStatus=false;

    Advisor.Utils.LoadLinkCharts(system);


    ft=ModelAdvisor.FormatTemplate('ListTemplate');
    ft.setSubTitle(DAStudio.message([xlateTagPrefix,'SFSignalsTitle']));
    ft.setInformation({DAStudio.message([xlateTagPrefix,'SFSignalsCheckDesc'])});
    if strcmp(xlateTagPrefix,'ModelAdvisor:styleguide:')
        msgStr=[DAStudio.message('ModelAdvisor:styleguide:MathWorksAutomotiveAdvisoryBoardChecks'),': db_0122'];
    end

    deviantSystems={};

    if(loc_IsModelReference(system)==true)



    else
        chartArray={};

        m=get_param(system,'Object');
        if~isempty(m)

            chartArray=m.find('-isa','Stateflow.Chart');

            linkCharts=ModelAdvisor.Common.find_LinkChart(m);
            chartArray=[chartArray(:);linkCharts(:)];
        end
    end


    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    if~isempty(deviantSystems)
        deviantSystems=mdladvObj.filterResultWithExclusion(deviantSystems);
    end

    if((length(deviantSystems))>0)
        bResultStatus=false;
        ft.setSubResultStatus('Warn');
        ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'SFSignalsFailMsg']));
        ft.setRecAction(DAStudio.message([xlateTagPrefix,'SFSignalsRecAction']));
        ft.setListObj(deviantSystems);
        for i=1:length(deviantSystems)

            chartStr=ModelAdvisor.Text(deviantSystems{i}.Path);
            chartStr.setHyperlink(['matlab: styleguideprivate(',...
            '''view_chart'',','''',system,''',',...
            '''',deviantSystems{i}.Path,''')']);
            linkStr=ModelAdvisor.Text('(Display Chart Properties)');
            linkStr.setHyperlink(['matlab: styleguideprivate(',...
            '''view_chart_dialog'',','''',system,''',',...
            '''',deviantSystems{i}.Path,''')']);


        end
    elseif(isempty(chartArray))

        bResultStatus=true;
        ft.setSubResultStatus('Pass');
        ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'NoChartsFound']));
    else


        bResultStatus=true;
        ft.setSubResultStatus('Pass');
        ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'SFSignalsPassedMsg']));

    end
    ft.setSubBar(0);
    ResultDescription{end+1}=ft;
end



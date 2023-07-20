function[rec]=styleguide_db_0137








    rec=ModelAdvisor.Check('mathworks.maab.db_0137');
    rec.Title=DAStudio.message('ModelAdvisor:styleguide:db0137Title');
    rec.TitleTips=DAStudio.message('ModelAdvisor:styleguide:db0137Tip');
    rec.setCallbackFcn(@db_0137_StyleOneCallback,'None','StyleOne');

    rec.Value=true;
    rec.LicenseName={styleguide_license,'Stateflow'};
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='db0137Title';
    rec.SupportExclusion=true;
    rec.SupportLibrary=true;

    rec.setLicense({styleguide_license,'Stateflow'});

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.register(rec);

end

function[ResultDescription]=db_0137_StyleOneCallback(system)

    feature('scopedaccelenablement','off');
    ResultDescription={};



    modelAdvisorObject=Simulink.ModelAdvisor.getModelAdvisor(system);
    modelAdvisorObject.setCheckResultStatus(false);


    ft=ModelAdvisor.FormatTemplate('ListTemplate');



    msgStr=[DAStudio.message('ModelAdvisor:styleguide:MathWorksAutomotiveAdvisoryBoardChecks'),': db_0137'];
    ft.setCheckText({DAStudio.message('ModelAdvisor:styleguide:db0137_Info')});



    m=get_param(system,'Object');
    if~isempty(m)

        chartArray=m.find('-isa','Stateflow.Chart');
    end


    chartArray=modelAdvisorObject.filterResultWithExclusion(chartArray);

    deviantCharts=[];
    deviantChartsNoD=[];
    deviantChartsMultD=[];
    deviantStates=[];
    deviantStatesNoD=[];
    deviantStatesMultD=[];


    if~isempty(chartArray)
        for i=1:length(chartArray)



            stateArray=[...
            chartArray(i).find('-isa','Stateflow.State','-depth',1);...
            chartArray(i).find('-isa','Stateflow.AtomicSubchart','-depth',1)];



            stateArray=recurseBoxes(stateArray,chartArray(i));
            if strcmp(chartArray(i).Decomposition,'EXCLUSIVE_OR')


                transArray=chartArray(i).find('-isa','Stateflow.Transition','-depth',1);
                countDefault=0;
                for k=1:length(transArray)

                    if isempty(transArray(k).Source)
                        asts=Stateflow.Ast.getContainer(transArray(k));


                        if isempty(asts.sections)||~isa(asts.sections{1},'Stateflow.Ast.ConditionSection')
                            countDefault=countDefault+1;
                        end
                    end
                end
                if countDefault==0&&~isempty(stateArray)
                    deviantChartsNoD{end+1}=chartArray(i);
                elseif countDefault>1
                    deviantChartsMultD{end+1}=chartArray(i);
                end








                if numel(stateArray)==1
                    deviantCharts{end+1}=chartArray(i);
                end


            end




            for j=1:length(stateArray)
                [deviantStates,deviantStatesNoD,deviantStatesMultD]=...
                checkValidState(stateArray(j),...
                deviantStates,...
                deviantStatesNoD,...
                deviantStatesMultD);
            end
        end
    end


    modelAdvisorObject.setCheckResultStatus(true);
    cr=sprintf('\n');
    systemLinkStr=strrep(bdroot(system),cr,'__CR__');
    ft1=ModelAdvisor.FormatTemplate('ListTemplate');
    ft1.setSubTitle({DAStudio.message('ModelAdvisor:styleguide:db0137ChartXOR_Title')});
    ft1.setInformation({DAStudio.message('ModelAdvisor:styleguide:db0137ChartXOR_Info')});

    if~isempty(deviantCharts)
        sids=cell(1,length(deviantCharts));
        for i=1:length(deviantCharts)
            sids{i}=Simulink.ID.getSID(deviantCharts{i});
        end
        ft1.setSubResultStatusText({ModelAdvisor.Text(DAStudio.message('ModelAdvisor:styleguide:db0137ChartXORFailMsg'))});
        ft1.setRecAction({DAStudio.message('ModelAdvisor:styleguide:db0137ChartXOR_RecAct')});
        ft1.setListObj(sids);
        ft1.setSubResultStatus('warn');
        modelAdvisorObject.setCheckResultStatus(false);

    else
        ft1.setSubResultStatusText({ModelAdvisor.Text(DAStudio.message('ModelAdvisor:styleguide:db0137ChartXORPassMsg'))});
        ft1.setSubResultStatus('pass');
    end

    ft2=ModelAdvisor.FormatTemplate('ListTemplate');
    ft2.setSubTitle({DAStudio.message('ModelAdvisor:styleguide:db0137ChartNoDefault_Title')});
    ft2.setInformation({DAStudio.message('ModelAdvisor:styleguide:db0137ChartNoDefault_Info')});

    if~isempty(deviantChartsNoD)
        sids=cell(1,length(deviantChartsNoD));
        for i=1:length(deviantChartsNoD)
            sids{i}=Simulink.ID.getSID(deviantChartsNoD{i});
        end

        ft2.setSubResultStatusText({ModelAdvisor.Text(DAStudio.message('ModelAdvisor:styleguide:db0137ChartNoDefaultFailMsg'))});
        ft2.setRecAction({DAStudio.message('ModelAdvisor:styleguide:db0137ChartNoDefault_RecAct')});
        ft2.setListObj(sids);
        ft2.setSubResultStatus('warn');
        modelAdvisorObject.setCheckResultStatus(false);

    else
        ft2.setSubResultStatusText({ModelAdvisor.Text(DAStudio.message('ModelAdvisor:styleguide:db0137ChartNoDefaultPassMsg'))});
        ft2.setSubResultStatus('pass');
    end

    ft3=ModelAdvisor.FormatTemplate('ListTemplate');
    ft3.setSubTitle({DAStudio.message('ModelAdvisor:styleguide:db0137ChartMultDefault_Title')});
    ft3.setInformation({DAStudio.message('ModelAdvisor:styleguide:db0137ChartMultDefault_Info')});

    if~isempty(deviantChartsMultD)
        sids=cell(1,length(deviantChartsMultD));
        for i=1:length(deviantChartsMultD)
            sids{i}=Simulink.ID.getSID(deviantChartsMultD{i});
        end

        ft3.setSubResultStatusText({ModelAdvisor.Text(DAStudio.message('ModelAdvisor:styleguide:db0137ChartMultDefaultFailMsg'))});
        ft3.setRecAction({DAStudio.message('ModelAdvisor:styleguide:db0137ChartMultDefault_RecAct')});
        ft3.setListObj(sids);
        ft3.setSubResultStatus('warn');
        modelAdvisorObject.setCheckResultStatus(false);
    else
        ft3.setSubResultStatusText({ModelAdvisor.Text(DAStudio.message('ModelAdvisor:styleguide:db0137ChartMultDefaultPassMsg'))});
        ft3.setSubResultStatus('pass');
    end

    ft4=ModelAdvisor.FormatTemplate('ListTemplate');
    ft4.setSubTitle({DAStudio.message('ModelAdvisor:styleguide:db0137StateXOR_Title')});
    ft4.setInformation({DAStudio.message('ModelAdvisor:styleguide:db0137StateXOR_Info')});

    if~isempty(deviantStates)
        sids=cell(1,length(deviantStates));
        for i=1:length(deviantStates)
            sids{i}=Simulink.ID.getSID(deviantStates{i});
        end

        ft4.setSubResultStatusText({ModelAdvisor.Text(DAStudio.message('ModelAdvisor:styleguide:db0137StateXORFailMsg'))});
        ft4.setRecAction({DAStudio.message('ModelAdvisor:styleguide:db0137StateXOR_RecAct')});
        ft4.setListObj(sids);
        ft4.setSubResultStatus('warn');
        modelAdvisorObject.setCheckResultStatus(false);
    else
        ft4.setSubResultStatusText({ModelAdvisor.Text(DAStudio.message('ModelAdvisor:styleguide:db0137StateXORPassMsg'))});
        ft4.setSubResultStatus('pass');
    end

    ft5=ModelAdvisor.FormatTemplate('ListTemplate');
    ft5.setSubTitle({DAStudio.message('ModelAdvisor:styleguide:db0137StateNoDefault_Title')});
    ft5.setInformation({DAStudio.message('ModelAdvisor:styleguide:db0137StateNoDefault_Info')});

    if~isempty(deviantStatesNoD)
        sids=cell(1,length(deviantStatesNoD));
        for i=1:length(deviantStatesNoD)
            sids{i}=Simulink.ID.getSID(deviantStatesNoD{i});
        end
        ft5.setSubResultStatusText({ModelAdvisor.Text(DAStudio.message('ModelAdvisor:styleguide:db0137StateNoDefaultFailMsg'))});
        ft5.setRecAction({DAStudio.message('ModelAdvisor:styleguide:db0137StateNoDefault_RecAct')});
        ft5.setListObj(sids);
        ft5.setSubResultStatus('warn');
        modelAdvisorObject.setCheckResultStatus(false);

    else
        ft5.setSubResultStatusText({ModelAdvisor.Text(DAStudio.message('ModelAdvisor:styleguide:db0137StateNoDefaultPassMsg'))});
        ft5.setSubResultStatus('pass');
    end

    ft6=ModelAdvisor.FormatTemplate('ListTemplate');
    ft6.setSubTitle({DAStudio.message('ModelAdvisor:styleguide:db0137StateMultDefault_Title')});
    ft6.setInformation({DAStudio.message('ModelAdvisor:styleguide:db0137StateMultDefault_Info')});

    if~isempty(deviantStatesMultD)
        sids=cell(1,length(deviantStatesMultD));
        for i=1:length(deviantStatesMultD)
            sids{i}=Simulink.ID.getSID(deviantStatesMultD{i});
        end

        ft6.setSubResultStatusText({ModelAdvisor.Text(DAStudio.message('ModelAdvisor:styleguide:db0137StateMultDefaultFailMsg'))});
        ft6.setRecAction({DAStudio.message('ModelAdvisor:styleguide:db0137StateMultDefault_RecAct')});
        ft6.setListObj(sids);
        ft6.setSubResultStatus('warn');
        modelAdvisorObject.setCheckResultStatus(false);
    else
        ft6.setSubResultStatusText({ModelAdvisor.Text(DAStudio.message('ModelAdvisor:styleguide:db0137StateMultDefaultPassMsg'))});
        ft6.setSubResultStatus('pass');
    end

    ResultDescription{end+1}=ft;
    ResultDescription{end+1}=ft1;
    ResultDescription{end+1}=ft2;
    ResultDescription{end+1}=ft3;
    ResultDescription{end+1}=ft4;
    ResultDescription{end+1}=ft5;
    ft6.setSubBar(0);
    ResultDescription{end+1}=ft6;

end



function[stateArray]=recurseBoxes(stateArray,rootObj)

    subBoxArray=rootObj.find('-isa','Stateflow.Box','-depth',1);
    if(~isempty(subBoxArray))

        bInB=subBoxArray.find('-isa','Stateflow.Box','-depth',1);
        if(length(bInB)>1)
            for i=2:length(bInB)
                [stateArray]=recurseBoxes(stateArray,bInB(i));
            end
        end

        for i=1:length(subBoxArray)

            statesInBox=subBoxArray(i).find('-isa','Stateflow.State','-depth',1);
            for jnx=1:length(statesInBox)
                stateArray(end+1)=statesInBox(jnx);%#ok<AGROW>
            end
        end
    end
end

function[ExOrStates,NoDStates,MultDStates]=...
    checkValidState(stateObj,...
    ExOrStates,...
    NoDStates,...
    MultDStates)








    subStateArray=[...
    stateObj.find('-isa','Stateflow.State','-depth',1);...
    stateObj.find('-isa','Stateflow.AtomicSubchart','-depth',1)];








    if isa(stateObj,'Stateflow.State')
        if strcmp(stateObj.Decomposition,'EXCLUSIVE_OR')
            doAnalyis=true;
        else
            doAnalyis=false;
        end
    elseif isa(stateObj,'Stateflow.AtomicSubchart')
        if strcmp(stateObj.Type,'OR')
            doAnalyis=true;
        else
            doAnalyis=false;
        end
    else
        doAnalyis=false;
    end


    if doAnalyis




        if length(subStateArray)>1
            transArray=stateObj.find('-isa','Stateflow.Transition','-depth',1);
            countDefault=0;
            for k=1:length(transArray)
                if isempty(transArray(k).Source)
                    asts=Stateflow.Ast.getContainer(transArray(k));


                    if isempty(asts.sections)||~isa(asts.sections{1},'Stateflow.Ast.ConditionSection')
                        countDefault=countDefault+1;
                    end
                end
            end
            if countDefault==0
                NoDStates{end+1}=stateObj;
            elseif countDefault>1
                MultDStates{end+1}=stateObj;
            end
        end






        if numel(subStateArray)==2
            ExOrStates{end+1}=stateObj;
        end


    end


    for j=2:length(subStateArray)
        [ExOrStates,NoDStates,MultDStates]=...
        checkValidState(subStateArray(j),...
        ExOrStates,...
        NoDStates,...
        MultDStates);
    end
end

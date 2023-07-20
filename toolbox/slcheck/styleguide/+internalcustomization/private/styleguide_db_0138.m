function rec=styleguide_db_0138






    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('ModelAdvisor:styleguide:db0138Title');
    rec.TitleID='StyleGuide: db_0138';
    rec.TitleTips=DAStudio.message('ModelAdvisor:styleguide:db0138Tip');
    rec.TitleInRAWFormat=false;
    rec.CallbackHandle=@db_0138_StyleThreeCallback;
    rec.CallbackContext='none';
    rec.CallbackStyle='StyleThree';
    rec.CallbackReturnInRAWFormat=false;
    rec.PushToModelExplorer=false;
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.Group=sg_maab_group;
    rec.LicenseName={styleguide_license,'Stateflow'};
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='db0138Title';

    function[ResultDescription,ResultHandles]=db_0138_StyleThreeCallback(system)

        feature('scopedaccelenablement','off');
        ResultDescription={};
        ResultHandles={};
        ResultDescription{end+1}=sg_maab_msg('db0138Tip');
        ResultHandles{end+1}=[];



        mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
        mdladvObj.setCheckResultStatus(false);



        rt=sfroot;
        m=rt.find('-isa','Simulink.BlockDiagram','-and',...
        'Name',system);




        listOfCharts=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks','on','MaskType','Stateflow');
        lib_chart=[];
        org_path=[];

        for i=1:length(listOfCharts)
            if strcmp(get_param(listOfCharts{i},'LinkStatus'),'resolved')
                lib_chart{end+1}=get_param(listOfCharts{i},'ReferenceBlock');
                org_path{end+1}=listOfCharts{i};
            end
        end

        lib_chart_u=unique(lib_chart);
        sourceChartObjects=get_source_charts_for_links_in_model(bdroot(system),lib_chart_u);
        chartArray=m.find('-isa','Stateflow.Chart');
        pathList={};
        linkList={};
        for i=1:length(chartArray)
            pathList{i}=chartArray(i).Path;
            linkList{i}=[];
        end
        for i=1:length(org_path)
            for j=1:length(sourceChartObjects)
                if strcmp(lib_chart{i},sourceChartObjects{j}.Path)
                    chartArray(end+1)=sourceChartObjects{j};
                    pathList{end+1}=org_path{i};
                    linkList{end+1}=lib_chart{i};
                end
            end
        end


        historyJ=[];
        historyHandles=[];
        failMsg=0;
        currentResult=[];
        for q=1:length(chartArray)
            historyJ=chartArray(q).find('-isa','Stateflow.Junction','-and','Type','HISTORY');


            currentResult=historyHandles;
            if isempty(historyJ)

            else
                if failMsg==0
                    failMsg=1;
                    currentDescription=DAStudio.message('ModelAdvisor:styleguide:db0138FailMsg');
                    ResultDescription{end+1}=currentDescription;
                    ResultHandles{end+1}=currentResult;
                end
                for i=1:length(historyJ)
                    path=historyJ(i).Path;
                    if isempty(linkList{q})==0
                        systemJ=linkList{q};
                        pathD=strrep(path,linkList{q},pathList{q});
                        chartP=pathList{q};
                    else
                        systemJ=system;
                        pathD=path;
                        chartP=pathList{q};
                    end
                    cr=sprintf('\n');
                    systemJ=strrep(systemJ,cr,'__CR__');
                    pathD=strrep(pathD,cr,'__CR__');
                    chartP=strrep(chartP,cr,'__CR__');
                    ResultDescription{end+1}=['<a href="matlab: styleguideprivate(','''view_junction''',',','''',systemJ,'''',',','''',path,'''',',','''',chartP,'''',')">',pathD,'</a>'];
                    ResultHandles{end+1}={};
                end
                mdladvObj.setCheckResultStatus(false);
            end

        end

        if failMsg==0
            currentDescription=DAStudio.message('ModelAdvisor:styleguide:PassedMsg');
            ResultDescription{end+1}=currentDescription;
            ResultHandles{end+1}=currentResult;
            mdladvObj.setCheckResultStatus(true);
        end

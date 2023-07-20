










function[bResultStatus,ResultDescription]=modelAdvisorCheck_SFPortNames(system,xlateTagPrefix)

    ResultDescription={};

    bResultStatus=false;%#ok<NASGU> % init to fail

    Advisor.Utils.LoadLinkCharts(system);

    ft=ModelAdvisor.FormatTemplate('ListTemplate');
    ft.setSubTitle(DAStudio.message([xlateTagPrefix,'SFPortNamesTitle']));
    ft.setInformation({DAStudio.message([xlateTagPrefix,'SFPortNamesCheckDesc'])});


    chartProps=loc_getChartObjects(system);






    issuePortHandles=[];

    for i=1:length(chartProps)


        c=chartProps(i).obj;











        if isempty(chartProps(i).slPathLib)
            subsysObj=get_param(chartProps(i).slPathModel,'Object');
        else
            subsysObj=get_param(chartProps(i).slPathLib,'Object');
        end

        for j=1:length(subsysObj.LineHandles.Inport)

            lineHandle=subsysObj.LineHandles.Inport(j);
            sfInputObject=c.find('Scope','Input','-and',...
            'Port',j,'-not','-isa','Stateflow.Event');
            name=loc_getInportLineName(lineHandle,sfInputObject);
            if~isempty(name)&&~strcmp(name,sfInputObject.Name)
                issuePortHandles=[issuePortHandles,...
                get_param(lineHandle,'SrcPorthandle')];%#ok<AGROW>
            end








        end

        for j=1:length(subsysObj.LineHandles.Outport)
            if subsysObj.LineHandles.Outport(j)>0

                lineObj=get_param(subsysObj.LineHandles.Outport(j),'Object');
                sp=lineObj.getSourcePort;
                sfOutputObject=c.find('Scope','Output','-and','Port',j);
                if~isempty(sp)&&~isempty(sp.Name)&&~strcmp(sp.Name,sfOutputObject.Name)
                    issuePortHandles=[issuePortHandles,lineObj.SrcPortHandle];%#ok<AGROW>
                end






            end
        end
    end


    if isempty(issuePortHandles)
        ft.setSubResultStatus('Pass');
        if isempty(chartProps)
            ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'NoChartsFound']));
        else
            ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'SFPortNamesPassedMsg']));
        end
        bResultStatus=true;
        ResultDescription{end+1}=ft;
    else
        ft.setSubResultStatus('Warn');
        ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'SFPortNamesFailMsg']));
        ft.setRecAction(DAStudio.message([xlateTagPrefix,'SFPortNamesRecAction']));
        ft.setListObj(issuePortHandles);
        bResultStatus=false;
        ResultDescription{end+1}=ft;
    end
end


function chartProps=loc_getChartObjects(system)





    chartProps=struct([]);


    bdObj=get_param(system,'Object');


    charts=bdObj.find('-isa','Stateflow.Chart');



    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    charts=mdladvObj.filterResultWithExclusion(charts);



    for n=1:length(charts)
        if~isa(charts(n).getParent(),'Stateflow.Chart')
            chartProps(end+1).obj=charts(n);%#ok<AGROW>
            chartProps(end).slPathModel=charts(n).Path;
            chartProps(end).slPathLib='';
        end
    end



    linkChartObjs=bdObj.find('-isa','Stateflow.LinkChart');

    if~isempty(linkChartObjs)
        libChartObjs=cell(size(linkChartObjs));
        isChart=false(size(linkChartObjs));

        for i=1:length(linkChartObjs)
            lcHndl=sf('get',linkChartObjs(i).Id,'.handle');
            cId=sfprivate('block2chart',lcHndl);
            c=idToHandle(sfroot,cId);



            if c.isa('Stateflow.Chart')&&~isa(c.getParent(),'Stateflow.Chart')
                libChartObjs{i}=c;
                isChart(i)=true;
            end
        end


        libChartObjs=libChartObjs(isChart);
        linkChartObjs=linkChartObjs(isChart);

        for n=1:length(libChartObjs)







            if strcmp(get_param(linkChartObjs(n).getFullName(),'LinkStatus'),'implicit')
                chartProps(end+1).obj=libChartObjs{n};%#ok<AGROW>
                chartProps(end).slPathLib=libChartObjs{n}.getFullName();
                chartProps(end).slPathModel=linkChartObjs(n).getFullName();
            end
        end
    end
end


function name=loc_getInportLineName(handle,inputDataObj)

    name='';

    if handle>0
        lineObj=get_param(handle,'Object');
        sp=lineObj.getSourcePort;




        if~isempty(sp)

            if isempty(sp.Name)
                name=sp.PropagatedSignals;

            else
                name=sp.Name;
                if strcmp(name(1),'<')&&strcmp(name(end),'>')
                    name(1)='';
                    name(end)='';
                end
            end
        end
    end
end
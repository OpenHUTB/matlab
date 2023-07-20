function[rec]=styleguide_jc_0541








    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('ModelAdvisor:styleguide:jc0541Title');
    rec.TitleID='mathworks.maab.jc_0541';
    rec.TitleTips=DAStudio.message('ModelAdvisor:styleguide:jc0541Tip');
    rec.TitleInRAWFormat=false;
    rec.CallbackHandle=@jc_0541_Callback;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleOne';
    rec.CallbackReturnInRAWFormat=false;
    rec.PushToModelExplorer=false;
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.Group=sg_maab_group;
    rec.LicenseName={styleguide_license};
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='jc0541Title';
    rec.SupportExclusion=true;
end

function[ResultDescription]=jc_0541_Callback(system)

    feature('scopedaccelenablement','off');
    ResultDescription={};

    modelAdvisorObject=Simulink.ModelAdvisor.getModelAdvisor(system);
    modelAdvisorObject.setCheckResultStatus(false);

    deviantSystems={};

    if(sLSGIsModelReference(system)==true)




    else

        machine=get_param(system,'Object');
        if~isempty(machine)

            tunableData=machine.find('-isa','Stateflow.Data',...
            '-and','Scope','Constant',...
            '-or','Scope','Parameter');
        end
        dataFlagged={};
        if~isempty(tunableData)
            for i=1:length(tunableData)

                if(evalin('base',['exist(''',tunableData(i).Name,''')'])==1)
                    if isa(evalin('base',tunableData(i).Name),'Simulink.Parameter')
                        dataFlagged{end+1}=tunableData(i);
                    end
                end
            end
        end
    end

    ft=ModelAdvisor.FormatTemplate('TableTemplate');
    msgStr=[DAStudio.message('ModelAdvisor:styleguide:MathWorksAutomotiveAdvisoryBoardChecks'),': jc_0541'];
    ft.setSubBar(0);
    ft.setCheckText({DAStudio.message('ModelAdvisor:styleguide:jc0541Desc')});
    ft.setColTitles({DAStudio.message('ModelAdvisor:styleguide:jc0541_Col_1'),...
    DAStudio.message('ModelAdvisor:styleguide:jc0541_Col_2')});


    dataFlagged=modelAdvisorObject.filterResultWithExclusion(dataFlagged);


    if~isempty(dataFlagged)
        modelAdvisorObject.setCheckResultStatus(false);

        cr=sprintf('\n');
        systemLinkStr=strrep(bdroot(system),cr,'__CR__');

        for inx=1:length(dataFlagged)

            chartObj=get_param(dataFlagged{inx}.Path,'Object');
            path=strrep([chartObj.Path,'/',chartObj.Name],cr,'__CR__');
            chartStr=['<a href="matlab: styleguideprivate(',...
            '''view_chart'',','''',systemLinkStr,''',',...
            '''',path,''')">',dataFlagged{inx}.Path,'</a>'];
            dataStr=['<a href="matlab: styleguideprivate(',...
            '''view_data'',','''',path,''',',...
            '''',dataFlagged{inx}.Name,''')">',...
            dataFlagged{inx}.Name,'</a>'];


            ft.addRow({chartStr,dataStr});
        end
        ft.setSubResultStatus('warn');
        ft.setRecAction({DAStudio.message('ModelAdvisor:styleguide:jc0541_RecAct')});
        ft.setSubResultStatusText({DAStudio.message('ModelAdvisor:styleguide:jc0541Error')});
    else


        ft.setSubResultStatus('pass');
        ft.setSubResultStatusText({DAStudio.message('ModelAdvisor:styleguide:jc0541_Pass')});
        modelAdvisorObject.setCheckResultStatus(true);
    end
    ResultDescription{end+1}=ft;
end



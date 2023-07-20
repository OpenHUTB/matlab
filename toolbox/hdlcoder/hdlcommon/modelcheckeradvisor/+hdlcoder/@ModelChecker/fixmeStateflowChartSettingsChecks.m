function ResultDescription=fixmeStateflowChartSettingsChecks(mdlTaskObj)







    ruleName='runStateflowChartSettingsChecks';
    mdlAdvObj=mdlTaskObj.MAObj;
    partiallyQualifiedCheckName=ruleName;
    UserData=mdlAdvObj.UserData(partiallyQualifiedCheckName);
    checker=UserData{1};

    List=ModelAdvisor.List;
    List.setType('bulleted');


    function fixExportChartFunctions(chart)
        chart.ExportChartFunctions=0;
    end


    function fixSupportVariableSizing(chart)
        chart.SupportVariableSizing=0;
    end


    function fixExecuteAtInitialization(chart)
        chart.ExecuteAtInitialization=1;
    end


    function fixActionLanguage(chart)
        chart.ActionLanguage='MATLAB';
    end

    fixedBlocks={};

    rt=sfroot;
    model=checker.m_sys;
    dut=checker.m_DUT;
    m=rt.find('-isa','Simulink.BlockDiagram','-and','Name',model);
    charts=m.find('-isa','Stateflow.Chart');


    for i=1:length(charts)
        if isempty(regexp(charts(i).Path,sprintf('^%s/',dut),'once'))
            continue;
        end

        if charts(i).ExecuteAtInitialization~=1
            fixExecuteAtInitialization(charts(i))
            txtObjAndLink=ModelAdvisor.Text(charts(i).Path);
            as_numeric_string=['char([',num2str(charts(i).Path+0),'])'];
            txtObjAndLink.setHyperlink(['matlab: hilite_system(',as_numeric_string,')']);
            List.addItem(txtObjAndLink);
            fixedBlocks{end+1}=[charts(i).Name,' was updated for ExecuteAtInitialization parameter'];%#ok<AGROW>
        end


        if charts(i).ExportChartFunctions==1
            fixExportChartFunctions(charts(i));
            txtObjAndLink=ModelAdvisor.Text(charts(i).Path);
            as_numeric_string=['char([',num2str(charts(i).Path+0),'])'];
            txtObjAndLink.setHyperlink(['matlab: hilite_system(',as_numeric_string,')']);
            List.addItem(txtObjAndLink);
            fixedBlocks{end+1}=[charts(i).Name,' was updated for ExportChartFunctions parameter'];%#ok<AGROW>
        end



        if~strcmpi(charts(i).ActionLanguage,'matlab')
            fixActionLanguage(charts(i));
            txtObjAndLink=ModelAdvisor.Text(charts(i).Path);
            as_numeric_string=['char([',num2str(charts(i).Path+0),'])'];
            txtObjAndLink.setHyperlink(['matlab: hilite_system(',as_numeric_string,')']);
            List.addItem(txtObjAndLink);
            fixedBlocks{end+1}=[charts(i).Name,' was updated for ActionLanguage parameter'];%#ok<AGROW>
        end



        if charts(i).SupportVariableSizing==1
            fixSupportVariableSizing(charts(i));
            txtObjAndLink=ModelAdvisor.Text(charts(i).Path);
            as_numeric_string=['char([',num2str(charts(i).Path+0),'])'];
            txtObjAndLink.setHyperlink(['matlab: hilite_system(',as_numeric_string,')']);
            List.addItem(txtObjAndLink);
            fixedBlocks{end+1}=[charts(i).Name,' was updated for SupportVariableSizing parameter'];%#ok<AGROW>
        end
    end

    ResultDescription=[ModelAdvisor.Text('Following blocks were modified:'),List];
end

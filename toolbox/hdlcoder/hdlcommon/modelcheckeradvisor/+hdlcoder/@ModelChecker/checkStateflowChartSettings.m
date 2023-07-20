function flag=checkStateflowChartSettings(this)





    flag=true;
    model=this.m_sys;
    dut=this.m_DUT;
    rt=sfroot;
    m=rt.find('-isa','Simulink.BlockDiagram','-and','Name',model);
    charts=m.find('-isa','Stateflow.Chart');



    for i=1:length(charts)
        if isempty(regexp(charts(i).Path,sprintf('^%s/',dut),'once'))
            continue;
        end

        if charts(i).ExecuteAtInitialization~=1
            this.addCheck('warning',DAStudio.message('HDLShared:hdlmodelchecker:desc_stateflow_settings'),charts(i).Path,1,DAStudio.message('HDLShared:hdlmodelchecker:desc_execute_initialization'));
            flag=false;
        end


        if~strcmpi(charts(i).ActionLanguage,'matlab')
            this.addCheck('warning',DAStudio.message('HDLShared:hdlmodelchecker:desc_stateflow_settings'),charts(i).Path,1,DAStudio.message('HDLShared:hdlmodelchecker:desc_action_language'));
            flag=false;
        end


        if charts(i).SupportVariableSizing==1
            this.addCheck('warning',DAStudio.message('HDLShared:hdlmodelchecker:desc_stateflow_settings'),charts(i).Path,1,DAStudio.message('HDLShared:hdlmodelchecker:desc_export_support_variable_size_array'));
            flag=false;
        end


        if charts(i).ExportChartFunctions==1
            this.addCheck('warning',DAStudio.message('HDLShared:hdlmodelchecker:desc_stateflow_settings'),charts(i).Path,1,DAStudio.message('HDLShared:hdlmodelchecker:desc_export_chart_functions'));
            flag=false;
        end
    end
end

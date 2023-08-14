function obj=qualifyData(data)



    obj=[];

    if iscell(data)
        data=data{1};
    end
    if isa(data,'Advisor.Text')
        obj.Data=data;
        obj.Type=ModelAdvisor.ResultDetailType.String;
    elseif Simulink.ID.isValid(data)


        obj.Data=data;
        obj.Type=ModelAdvisor.ResultDetailType.SID;

    elseif isa(data,'Stateflow.Data')

        if isa(idToHandle(sfroot,sf('ParentOf',data.Id)),'Stateflow.Machine')
            obj.Model=Simulink.ID.getSID(data.Machine);
            obj.Data=data.Name;
            obj.Type=ModelAdvisor.ResultDetailType.RootLevelStateflowData;
        else

            obj.Data=Simulink.ID.getSID(data);
            obj.Type=ModelAdvisor.ResultDetailType.SID;
        end
    elseif ischar(data)
        obj.Data=data;
        obj.Type=ModelAdvisor.ResultDetailType.String;
    elseif isa(data,'Simulink.VariableUsage')
        obj.Type=ModelAdvisor.ResultDetailType.SimulinkVariableUsage;
        obj=ModelAdvisor.ResultDetail.loc_handle_slVarUsage(obj,data);
    else

        try
            obj.Data=Simulink.ID.getSID(data);
        catch
            error(message('ModelAdvisor:engine:MAUnknownType'));
        end

        obj.Type=ModelAdvisor.ResultDetailType.SID;

    end
end
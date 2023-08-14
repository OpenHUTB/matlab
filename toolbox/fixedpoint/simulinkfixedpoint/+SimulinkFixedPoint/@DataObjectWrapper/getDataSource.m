function dataSource=getDataSource(this)




    dataSource=[];
    switch this.WorkspaceType


    case{SimulinkFixedPoint.AutoscalerVarSourceTypes.Base,...
        SimulinkFixedPoint.AutoscalerVarSourceTypes.DataDictionary}

        if~isempty(this.ContextName)

            dataSource=Simulink.data.DataSource.create(this.ContextName);
        else
            dataSource=Simulink.data.BaseWorkspace;
        end
    case SimulinkFixedPoint.AutoscalerVarSourceTypes.Model
        if~isempty(this.Context)

            dataSource=this.Context.ModelWorkspace;
        end
    end
end



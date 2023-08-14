classdef DataObjectWrapper<handle













    properties(SetAccess=private)
        Context=[];
        ContextName='';
        DataClassType='';
        EntityAutoscalerID='';
        Name='';
        Object=[];
        WorkspaceType=SimulinkFixedPoint.AutoscalerVarSourceTypes.Unknown;
    end
    methods(Access={?SimulinkFixedPoint.WrapperCreator})
        function obj=DataObjectWrapper()

        end
        setObject(this,object)
        setName(this,name)
        setWorkspaceType(this,workspaceType)
        setContextName(this,contextName)
        setDataClassType(this,dataClassType)
        setEntityAutoscalerID(this,entityAutoscalerID)
        executePrebuildOperations(this)
        rectifyWorkspaceType(this)
    end
    methods(Hidden)
        classOfDataObject=class(this)
        className=getFullName(this)
        isaClass=isa(this,className)
        dataSource=getDataSource(this)
    end

end



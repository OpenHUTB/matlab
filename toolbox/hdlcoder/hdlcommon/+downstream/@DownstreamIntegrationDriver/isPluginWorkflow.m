function result=isPluginWorkflow(obj,varargin)


    result=false;
    if(obj.havePIM)
        allPluginWorkflows=obj.pim.driverGetWorkflowNameList();
        if(nargin==2)
            currWorkflow=varargin{1};
        else
            currWorkflow=obj.get('Workflow');
        end
        result=any(strcmp(currWorkflow,allPluginWorkflows));
    end
end

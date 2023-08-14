function checkInstanceIDs=getSelectedCheckInstances(this,varargin)
    p=inputParser();
    p.addParameter('Group','',@(x)ischar(x));
    p.parse(varargin{:});
    inputs=p.Results;

    if~isempty(inputs.Group)
        checkInstanceIDs=this.TaskManager.getSelectedTasks('GroupID',inputs.Group);
    else
        checkInstanceIDs=this.TaskManager.getSelectedTasks();
    end
end
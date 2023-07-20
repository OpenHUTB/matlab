



function setupExternalRun(this,selectedTaskIDs,varargin)
    p=inputParser();


    p.addParameter('ComponentManager',[]);
    p.parse(varargin{:});
    inputs=p.Results;

    if this.MultiMode&&~isempty(inputs.ComponentManager)
        this.ComponentManager=inputs.ComponentManager;


        inputs.ids={};
        inputs.type=[];
        inputs.status=true;
        this.applyComponentSelection(inputs);

        this.setupRun();
    elseif isempty(this.ComponentManager)||~this.ComponentManager.IsInitialized
        this.setupRun();
    end


    taskObjIndexCellArray=this.TaskManager.taskIDs2Indices(selectedTaskIDs);
    maObj=this.getRootMAObj();

    for n=1:length(taskObjIndexCellArray)
        check=maObj.TaskAdvisorCellArray{taskObjIndexCellArray{n}}.Check;

        if Advisor.CompileModes.char2mode(check.CallbackContext)==...
            Advisor.CompileModes.CGIR
            Advisor.RegisterCGIRInspectors.getInstance.addInspectors(check.ID);
        end
    end
end
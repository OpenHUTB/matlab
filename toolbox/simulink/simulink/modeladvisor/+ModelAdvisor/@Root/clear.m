function clear(this,varargin)





    if nargin<2
        this.CheckIDMap=containers.Map();

        this.noncompileCheckList={};
        this.diyCheckList={};
        this.compileCheckList={};
        this.compileForCodegenCheckList={};
        this.cgirCheckList={};
        this.sldvCheckList={};

        this.TaskList={};
        this.missLicenseTaskList={};
        this.missLicenseCheckList={};

        this.OrderedTaskAdvisorNodes={};
        this.TaskAdvisorNodeID2Index=containers.Map;

        this.allCallBackFcnListName={};
        this.taskCallBackFcnListName={};
        this.nodeCount=0;
        this.CallbackErrorMsg={};
        this.IsCustomCheck=true;
    else
        this.OrderedTaskAdvisorNodes={};
        this.nodeCount=0;
        this.TaskAdvisorNodeID2Index=containers.Map;
    end

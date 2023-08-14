function hWorkflowList=getWorkflowList(varargin)











    if nargin==0
        hWorkflowList=hdlworkflow.WorkflowList.getInstance();
    else
        hWorkflowList=hdlworkflow.WorkflowList.getInstance(varargin{:});
    end


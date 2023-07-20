function hdlwaDriver=getWorkflowAdvisorDriver(this)





    if isempty(this.WorkflowAdvisorDriver)
        this.WorkflowAdvisorDriver=hdlwa.hdlwaDriver;
    end

    hdlwaDriver=this.WorkflowAdvisorDriver;


function res=isUnderDeactiveWorkflow(this)




    res=false;

    if~this.Selected
        res=true;
        return;
    else
        if isa(this.up,'Simulink.TaskAdvisor')
            res=this.up.isUnderDeactiveWorkflow;
        end
    end



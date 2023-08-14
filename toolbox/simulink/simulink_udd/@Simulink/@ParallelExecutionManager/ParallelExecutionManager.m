function this=ParallelExecutionManager(model,children)

    this=Simulink.ParallelExecutionManager;
    this.model=get_param(model,'handle');
    this.executionNodes=children;
    this.ModelHandleString=num2str(this.model);
    for i=1:length(children)
        children(i).root=this;
    end
end

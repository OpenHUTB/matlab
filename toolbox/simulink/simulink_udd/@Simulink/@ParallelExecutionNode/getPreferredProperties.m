function props=getPreferredProperties(this)



    props={'NodeName';'ExecutionMode'};
    if~isempty(this.PreviousExecutionMode)
        props=[props;'PreviousExecutionMode'];
    end
    if this.ParallelExecutionTime>0
        props=[props;'ParallelExecutionTime'];
    end
    if this.SerialExecutionTime>0
        props=[props;'SerialExecutionTime'];
    end


function this=ParallelExecutionNode(node)
    this=Simulink.ParallelExecutionNode;
    this.NodeName=node.nodeName;
    this.NodeType='ForEach';
    this.name='ForEach';
    this.root=handle(0);
    this.ExecutionMode=executionModeString(node.executionMode);
    this.ParallelExecutionTime=-1;
    if(isfield(node,'parallelExecutionTime'))
        this.ParallelExecutionTime=node.parallelExecutionTime;
    end
    this.SerialExecutionTime=-1;
    if(isfield(node,'serialExecutionTime'))
        this.SerialExecutionTime=node.serialExecutionTime;
    end
    this.PreviousExecutionMode='';
    if(isfield(node,'previousExecutionMode'))
        this.PreviousExecutionMode=...
        executionModeString(node.previousExecutionMode);
    end
end

function str=executionModeString(executionMode)
    switch(executionMode)
    case-1
        str='Auto';
    case 0
        str='Off';
    case 1
        str='On';
    end
end

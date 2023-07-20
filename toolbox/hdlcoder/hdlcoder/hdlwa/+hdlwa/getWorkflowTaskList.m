function taskList=getWorkflowTaskList(varargin)







    persistent WorkflowTasks;
    persistent currentKey;


    if isempty(WorkflowTasks)
        WorkflowTasks=containers.Map('KeyType','char','ValueType','any');
        currentKey='';
    end





    p=inputParser;
    p.addParameter('DownstreamObject',[]);
    p.addParameter('ClearCurrentKey',false);
    p.parse(varargin{:});
    inputArgs=p.Results;


    hDI=inputArgs.DownstreamObject;




    if(inputArgs.ClearCurrentKey)
        currentKey='';
        return;
    end







    currentWorkflow=hDI.get('Workflow');
    if(hDI.isPluginWorkflow)
        [key,keyTerms]=hDI.pim.createKeyAndKeyTerms(hDI);

    elseif hDI.hWorkflowList.isInWorkflowList(currentWorkflow)

        hWorkflow=hDI.hWorkflowList.getWorkflow(currentWorkflow);
        [key,keyTerms]=hWorkflow.hdlwa_getWorkflowTaskKey(hDI);

    else
        isCosim=hDI.GenerateTestbench&&hDI.isCosimEnabledOnModel;
        switch currentWorkflow
        case 'Generic ASIC/FPGA'

            keyTerms={hDI.get('Tool'),isCosim};
            key=[hDI.get('Workflow'),hDI.get('Tool'),num2str(isCosim)];
        case 'FPGA Turnkey'

            keyTerms={hDI.get('Tool')};
            key=[hDI.get('Workflow'),hDI.get('Tool')];
        case{'IP Core Generation','Deep Learning Processor'}

            keyTerms={hDI.showEmbeddedTasks,hDI.isShowTargetFrequencyTask,hDI.isShowCustomSWModelGenerationTask,hDI.isBoardEmpty};
            key=[hDI.get('Workflow'),num2str(hDI.showEmbeddedTasks),num2str(hDI.isShowTargetFrequencyTask),num2str(hDI.isShowCustomSWModelGenerationTask),num2str(hDI.isBoardEmpty)];
        case 'Simulink Real-Time FPGA I/O'
            keyTerms={hDI.get('Tool'),hDI.isIPCoreGen,hDI.showEmbeddedTasks,hDI.isShowTargetFrequencyTask};
            key=[hDI.get('Workflow'),hDI.get('Tool'),num2str(hDI.isIPCoreGen),num2str(hDI.showEmbeddedTasks),num2str(hDI.isShowTargetFrequencyTask)];
        case 'FPGA-in-the-Loop'
            keyTerms={isCosim};
            key=[hDI.get('Workflow'),num2str(isCosim)];
        case 'Customization for the USRP(R) Device'
            keyTerms={isCosim};
            key=[hDI.get('Workflow'),num2str(isCosim)];

        end
    end









    if strcmpi(key,currentKey)
        taskList=[];
        return;
    elseif(WorkflowTasks.isKey(key))
        taskList=WorkflowTasks(key);
        currentKey=key;
        return;
    elseif(hDI.isPluginWorkflow)
        taskList=hDI.pim.createTaskList(hDI.get('Workflow'),keyTerms);
    else
        taskList=hdlwa.createTaskList(hDI,hDI.get('Workflow'),keyTerms);
    end





    WorkflowTasks(key)=taskList;
    currentKey=key;

end


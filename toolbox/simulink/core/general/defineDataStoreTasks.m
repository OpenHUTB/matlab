function taskCellArray=defineDataStoreTasks


































    taskCellArray={};


    task=Simulink.MdlAdvisorTask;
    task.Title=DAStudio.message('Simulink:tools:MASimPnATaskTitle');
    task.TitleID='ModelAdvisor:Task:PerformanceAndAccuracy';
    task.TitleTips=DAStudio.message('Simulink:tools:MASimPnATaskTitleTip');
    task.CheckTitleIDs={'mathworks.design.NonContSigDerivPort'};
    task.Visible=true;
    task.Enable=true;
    task.Value=false;
    taskCellArray{end+1}=task;

    task=Simulink.MdlAdvisorTask;
    task.Title=DAStudio.message('Simulink:tools:MASimRuntimeAccuracyTaskTitle');
    task.TitleID='ModelAdvisor:Task:RuntimeAccuracy';
    task.TitleTips=DAStudio.message('Simulink:tools:MASimRuntimeAccuracyTaskTitleTip');
    task.CheckTitleIDs={'mathworks.design.DiagnosticSFcn',...
    'mathworks.design.DiagnosticDataStoreBlk'};
    task.Visible=true;
    task.Enable=true;
    task.Value=false;
    taskCellArray{end+1}=task;

    task=Simulink.MdlAdvisorTask;
    task.Title=DAStudio.message('Simulink:tools:MADataStoreBlocksTaskTitle');
    task.TitleID='ModelAdvisor:Task:DataStoreBlocks';
    task.TitleTips=DAStudio.message('Simulink:tools:MADataStoreBlocksTaskTitleTip');
    task.CheckTitleIDs={...
    'mathworks.design.DataStoreMemoryBlkIssue',...
    'mathworks.design.DataStoreBlkSampleTime',...
    'mathworks.design.OrderingDataStoreAccess',...
    'mathworks.design.datastoresimrtwcmp',...
    };
    task.Visible=true;
    task.Enable=true;
    task.Value=false;
    taskCellArray{end+1}=task;

end






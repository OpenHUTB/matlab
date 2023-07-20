


function setTargetHardware(modelName,boardName)

    fixedStepParamList={'SolverType','Solver',...
    'FixedStep','SampleTimeConstraint',...
    'EnableMultiTasking','ConcurrentTasks','AutoInsertRateTranBlk','PositivePriorityOrder'};

    varStepParamList={'SolverType','Solver',...
    'MaxStep','RelTol','MinStep','AbsTol','InitialStep','AutoScaleAbsTol',...
    'ShapePreserveControl','MaxConsecutiveMinStep',...
    'ZeroCrossControl','ZeroCrossAlgorithm','ConsecutiveZCsStepRelTol','ZcThreshold','MaxConsecutiveZCs',...
    'AutoInsertRateTranBlk','PositivePriorityOrder'};

    solverType=get_param(modelName,'SolverType');
    switch solverType
    case 'Fixed-step'
        plist=fixedStepParamList;
    case 'Variable-step'
        plist=varStepParamList;
    otherwise
        error('(unknown solver type)');
    end


    numP=length(plist);
    savedP=cell2struct(cell([1,numP]),plist,2);
    for pname=plist
        savedP.(pname{1})=get_param(modelName,pname{1});
    end


    set_param(modelName,'HardwareBoard',boardName);


    for pname=plist
        set_param(modelName,pname{1},savedP.(pname{1}));
    end






end


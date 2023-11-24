function recordCellArray=defineIEC61508ModelAdvisorChecks

    recordCellArray={};


    recordCellArray{end+1}=IEC61508_ModelVersionInfo;
    recordCellArray{end+1}=IEC61508_ModelMetricsInfo;
    recordCellArray{end+1}=IEC61508_UnconnectedObjects;
    recordCellArray{end+1}=IEC61508_QuestionableBlocks;
    IEC61508_StateflowProperUsage;

    IEC61508_MathOperationsBlocksUsage;
    IEC61508_LogicBitOpsBlocksUsage;
    IEC61508_PortsSubsystemsUsage;

end

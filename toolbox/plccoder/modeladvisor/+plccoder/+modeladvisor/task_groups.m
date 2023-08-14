function taskGroups = task_groups()
% Create and publish groups under By Tasks.

%   Copyright 2020 The MathWorks, Inc.

    modelAdvisorRoot = ModelAdvisor.Root;

    % PLC Model Advisor Group
    taskGroups.root = ModelAdvisor.FactoryGroup('SimulinkPLCCoder');
    taskGroups.root.DisplayName = DAStudio.message('plccoder:modeladvisor:ProductName');
    taskGroups.root.Description = DAStudio.message('plccoder:modeladvisor:ProductDescription');
    taskGroups.root.CSHParameters.MapKey = 'plcmodeladvisor';
    taskGroups.root.CSHParameters.TopicID = 'plcmodeladvisor_help_button';

    % Model Level Checks Subgroup
    taskGroups.modelLevelChecks = ModelAdvisor.FactoryGroup('SimulinkPLCCoder.ModelLevelChecks');
    taskGroups.modelLevelChecks.DisplayName = DAStudio.message('plccoder:modeladvisor:ModelLevelChecksName');
    taskGroups.modelLevelChecks.Description = DAStudio.message('plccoder:modeladvisor:ModelLevelChecksDescription');
    taskGroups.modelLevelChecks.CSHParameters.MapKey = 'plcmodeladvisor';
    taskGroups.modelLevelChecks.CSHParameters.TopicID = 'mathworks.PLC.ModelAdvisor.Group_ModelLevelChecks';
    taskGroups.root.addFactoryGroup(taskGroups.modelLevelChecks);
    modelAdvisorRoot.publish(taskGroups.modelLevelChecks);

    % Subsystem Level Checks Subgroup
    % taskGroups.subsystemLevelChecks = ModelAdvisor.FactoryGroup('SimulinkPLCCoder.SubsystemLevelChecks');
    % taskGroups.subsystemLevelChecks.DisplayName = DAStudio.message('plccoder:modeladvisor:SubsystemLevelChecksName');
    % taskGroups.subsystemLevelChecks.Description = DAStudio.message('plccoder:modeladvisor:SubsystemLevelChecksDescription');
    % taskGroups.subsystemLevelChecks.CSHParameters.MapKey = 'plcmodeladvisor';
    % taskGroups.subsystemLevelChecks.CSHParameters.TopicID = 'mathworks.PLC.ModelAdvisor.Group_SubsystemLevelChecks';
    % taskGroups.root.addFactoryGroup(taskGroups.subsystemLevelChecks);
    % modelAdvisorRoot.publish(taskGroups.subsystemLevelChecks);

    % Block Level Checks Subgroup
    taskGroups.blockLevelChecks = ModelAdvisor.FactoryGroup('SimulinkPLCCoder.BlockLevelChecks');
    taskGroups.blockLevelChecks.DisplayName = DAStudio.message('plccoder:modeladvisor:BlockLevelChecksName');
    taskGroups.blockLevelChecks.Description = DAStudio.message('plccoder:modeladvisor:BlockLevelChecksDescription');
    taskGroups.blockLevelChecks.CSHParameters.MapKey = 'plcmodeladvisor';
    taskGroups.blockLevelChecks.CSHParameters.TopicID = 'mathworks.PLC.ModelAdvisor.Group_BlockLevelChecks';
    taskGroups.root.addFactoryGroup(taskGroups.blockLevelChecks);
    modelAdvisorRoot.publish(taskGroups.blockLevelChecks);

    % Industry Standard Checks Subgroup
    taskGroups.industryStandardChecks = ModelAdvisor.FactoryGroup('SimulinkPLCCoder.IndustryStandardChecks');
    taskGroups.industryStandardChecks.DisplayName = DAStudio.message('plccoder:modeladvisor:IndustryStandardChecksName');
    taskGroups.industryStandardChecks.Description = DAStudio.message('plccoder:modeladvisor:IndustryStandardChecksDescription');
    taskGroups.industryStandardChecks.CSHParameters.MapKey = 'plcmodeladvisor';
    taskGroups.industryStandardChecks.CSHParameters.TopicID = 'mathworks.PLC.ModelAdvisor.Group_IndustryStandardChecks';
    taskGroups.root.addFactoryGroup(taskGroups.industryStandardChecks);
    modelAdvisorRoot.publish(taskGroups.industryStandardChecks);

    modelAdvisorRoot.publish(taskGroups.root);

end

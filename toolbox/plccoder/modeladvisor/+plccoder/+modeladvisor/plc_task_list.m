function taskGroups = plc_task_list(taskGroups)
% Add checks to published groups under By Tasks.

%   Copyright 2020 The MathWorks, Inc.

%% Industry Standard Checks
taskGroups.industryStandardChecks.addCheck('mathworks.PLC.NamesToAvoid');
taskGroups.industryStandardChecks.addCheck('mathworks.PLC.UseOfCase');
taskGroups.industryStandardChecks.addCheck('mathworks.PLC.AcceptableNameLength');
taskGroups.industryStandardChecks.addCheck('mathworks.PLC.Comments');
taskGroups.industryStandardChecks.addCheck('mathworks.PLC.NestedComments');
taskGroups.industryStandardChecks.addCheck('mathworks.PLC.MaxInOut');
% Post Compile for Codegen Context; Keep at last
taskGroups.industryStandardChecks.addCheck('mathworks.PLC.TypePrefixCheck');

%% Block Level Checks
taskGroups.blockLevelChecks.addCheck('mathworks.PLC.EventBlockCheck');
taskGroups.blockLevelChecks.addCheck('mathworks.PLC.ProbeBlockCheck');
taskGroups.blockLevelChecks.addCheck('mathworks.PLC.EnvControllerBlockCheck');
taskGroups.blockLevelChecks.addCheck('mathworks.PLC.ChartUpdateCheck');
taskGroups.blockLevelChecks.addCheck('mathworks.PLC.IntegratorBlockCheck');
taskGroups.blockLevelChecks.addCheck('mathworks.PLC.UnsupportedBlockCheck');
taskGroups.blockLevelChecks.addCheck('mathworks.PLC.TestBenchWithoutIOCheck');
taskGroups.blockLevelChecks.addCheck('mathworks.PLC.NonReusableSubSystemCheck');
% Post Compile for Codegen Context; Keep at last
taskGroups.blockLevelChecks.addCheck('mathworks.PLC.TrigonometricBlockCheck');

%% Model Level Checks
taskGroups.modelLevelChecks.addCheck('mathworks.PLC.DSMResolveToSLSignal');
taskGroups.modelLevelChecks.addCheck('mathworks.PLC.SFMessagesCheck');
taskGroups.modelLevelChecks.addCheck('mathworks.PLC.LineResolveToSLSignalCheck');
taskGroups.modelLevelChecks.addCheck('mathworks.PLC.RowMajorCheck');
taskGroups.modelLevelChecks.addCheck('mathworks.PLC.MaskParamInfCheck');
taskGroups.modelLevelChecks.addCheck('mathworks.PLC.MachineParentedDataCheck');
taskGroups.modelLevelChecks.addCheck('mathworks.PLC.CustomCodeCheck');
% Post Compile for Codegen Context; Keep at last
taskGroups.modelLevelChecks.addCheck('mathworks.PLC.TunableParamInfCheck');
end

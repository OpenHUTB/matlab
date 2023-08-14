function plc_check_list()
% Create and publish checks under By Product.

%   Copyright 2020 The MathWorks, Inc.

import plccoder.modeladvisor.checks.*

%% Industry Standard Checks
registerNamesToAvoidCheck;
registerUseOfCaseCheck;
registerAcceptableNameLengthCheck;
registerCommentsCheck;
registerNestedCommentsCheck;
registerMaxInOutCheck;
% Post Compile for Codegen Context; Keep at last
registerTypePrefixCheck;

%% Block Level Checks
EventBlockCheck.getInstance.register;
ProbeBlockCheck.getInstance.register;
EnvControllerBlockCheck.getInstance.register;
ChartUpdateCheck.getInstance.register;
IntegratorBlockCheck.getInstance.register;
UnsupportedBlockCheck.getInstance.register;
TestBenchWithoutIOCheck.getInstance.register;
NonReusableSubSystemCheck.getInstance.register;
% Post Compile for Codegen Context; Keep at last
TrigonometricBlockCheck.getInstance.register;

%% Model Level Checks
DSMResolveToSLSignal.getInstance.register;
SFMessagesCheck.getInstance.register;
LineResolveToSLSignalCheck.getInstance.register;
RowMajorCheck.getInstance.register;
MaskParamInfCheck.getInstance.register;
MachineParentedDataCheck.getInstance.register;
CustomCodeCheck.getInstance.getInstance.register;
% Post Compile for Codegen Context; Keep at last
TunableParamInfCheck.getInstance.register;
end

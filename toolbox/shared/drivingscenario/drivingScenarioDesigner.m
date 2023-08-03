function varargout = drivingScenarioDesigner(varargin)
%drivingScenarioDesigner Design driving scenarios, configure sensors, and
%generate synthetic detections
%
%   drivingScenarioDesigner opens the Driving Scenario Designer app for
%   designing drivingScenario objects, configuring vision and radar
%   detection generators, and generating synthetic sensor data. 
%
%   drivingScenarioDesigner(sessionFileName) opens the app and loads the
%   specified scenario file that was previously saved from the app.
%
%   drivingScenarioDesigner(scenario) opens the app and loads the specified
%   drivingScenario object into the app.  Actor ClassID properties must
%   correspond to the defaults in the app.
%
%   drivingScenarioDesigner(..., sensors) opens the app and loads the sensor
%   detection generator objects into the app. To load multiple radar or vision
%   sensors, use a cell array.
%
%   Notes
%   --------
%   - You can load Euro NCAP test procedures and other prebuilt scenarios.
%   - You can import OpenDRIVE roads into a driving scenario.
%
%   Example: Open Driving Scenario Designer with a prebuilt scenario.
%   -----------------------------------------------------------------------
%   % Open an automatic emergency braking scenario of a nearside collision with a
%   % pedestrian child. At collision time, the point of impact between the vehicle 
%   % and the child is at 50% of the vehicle's width.
%
%   Path = genpath(fullfile(matlabroot,'toolbox','shared','drivingscenario','PrebuiltScenarios'));
%   addpath(Path); % put scenario on path 
% 
%   drivingScenarioDesigner('AEB_PedestrianChild_Nearside_50width.mat');
% 
%   rmpath(Path); % remove scenario from path
%
%
%   See also drivingScenario, radarDetectionGenerator,
%   visionDetectionGenerator

%   Copyright 2021 The MathWorks, Inc.

% 确认MATLAB JVM™ 的Java功能是否可用
% 尝试显示 Java Frame 之前 AWT GUI 组件是否可用
if ~usejava('jvm') || ~usejava('awt')
    error(message('Spcuilib:application:ErrorNoJVMNoDisplay', getString(message('driving:scenarioApp:ScenarioBuilderName'))));
end

[varargout{1:nargout}] = matlabshared.application.launchApplication(...
    @driving.internal.scenarioApp.Designer, varargin{:});

% [EOF]

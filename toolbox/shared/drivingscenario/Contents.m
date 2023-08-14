% Design synthetic driving scenarios for testing your autonomous driving systems
%
% Version 5.4 (R2022b) 13-May-2022
%
% Driving Scenario Generation
%   drivingScenarioDesigner                 - App for designing driving scenarios and detection generators
%   drivingScenario                         - Generate driving scenario
%   drivingScenario/actor                   - Create a generic actor
%   drivingScenario/barrier                 - Create a barrier
%   drivingScenario/vehicle                 - Create a vehicle
%   drivingScenario/road                    - 创建道路
%   drivingScenario/parkingLot              - Create a parking lot
%   drivingScenario/plot                    - Create a plot
%   drivingScenario/roadNetwork             - Import road network into the scenario
%   drivingScenario/roadGroup               - Create and attach a new intersection to the driving scenario
%   driving.scenario.Actor/smoothTrajectory - Specify smooth, jerk-limited trajectory of actors and vehicles
%   driving.scenario.Actor/trajectory       - Specify trajectory of actors and vehicles
%   drivingScenario/advance                 - Move simulation forward by one time interval
%   drivingScenario/record                  - Record entire simulation
%   drivingScenario/actorProfiles           - Retrieve physical attributes for each actor
%   drivingScenario/actorPoses              - Retrieve positional information for each actor
%   driving.scenario.Actor/targetPoses      - Retrieve positional information relative to a specific actor
%   driving.scenario.Actor/targetOutlines   - Retrieve rectangular actor outlines relative to a specific actor
%   drivingScenario/roadBoundaries          - Retrieve road boundaries
%   drivingScenario/laneMarkingVertices     - Retrieve vertices of lane markings
%   drivingScenario/export                  - Export the driving scenario to External Standard file
%   parkingSpace                            - Create a specification for a parkingSpace in drivingScenario/parkingLot
%   lanespec                                - Create a specification for lanes in drivingScenario/road
%   laneSpecConnector                       - Connect two road segments with multiple lane specifications
%   compositeLaneSpec                       - Create a composite lane specification object to add or drop lane from the road
%   laneMarking                             - Construct a lane marking object of the given LaneBoundaryType 
%   laneType                                - Construct a lane type object of the given LaneTypes

% Copyright 2016-2020 The MathWorks, Inc.

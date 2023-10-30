classdef drivingScenario < driving.scenario.mixin.RoadNetwork & matlab.mixin.CustomDisplay
%drivingScenario Driving scenario
%   drivingScenario is used to generate a traffic scenario consisting of 
%   roads and actors placed in a 3D environment.  
%
%   scenario = drivingScenario creates an empty driving scenario.
%
%   To use a drivingScenario, populate it with roads, vehicles, or other
%   actors by creating them via their respective methods listed below. Once
%   all desired objects are created, you may simulate by calling the
%   advance method in a loop, or by calling the record method to run the
%   simulation all at once.
%
%   scenario = drivingScenario(Name,Value) sets the SampleTime, StopTime,
%   and GeoReference properties using name-value pairs.
%
%   drivingScenario properties:
%
%   SampleTime           - duration of time between updates
%   StopTime             - time at which to stop simulation
%   SimulationTime       - current time of the simulation
%   IsRunning            - true if the simulation is still running
%   Actors               - an array of actors and vehicles in the simulation
%   Barriers             - an array of barriers in the simulation
%   ParkingLots          - an array of parking lots in the simulation
%   GeoReference         - geographic coordinates of road network origin (read-only)
%
%   drivingScenario methods:
%
%   actor             - create a new generic actor
%   vehicle           - create a new vehicle actor
%   barrier           - create a new barrier
%   road              - create a new road 
%   parkingLot        - create a new parking lot
%   roadNetwork       - import a road network into the scenario
%   plot              - create a plot of the scenario
%   updatePlots       - update all plots with most recent actor positions
%   advance           - move simulation forward by one update interval
%   restart           - restart simulation at beginning
%   record            - runs entire simulation, recording into a struct
%   actorProfiles     - retrieve physical attributes of each actor
%   actorPoses        - retrieve positional information for each actor
%   roadBoundaries    - retrieve list of road boundaries
%   export            - export road network in driving scenario to open standard
%   roadGroup         - Create and attach a new intersection to the driving scenario
%
%   scenario = drivingScenario('GeoReference', [lat, lon, alt])
%   creates an empty driving scenario with geographic coordinates of the
%   road network origin, specified as a three-element numeric row vector of
%   the form [lat, lon, alt]. Here, lat is the latitude of the coordinate
%   in degrees, lon is the longitude of the coordinate in degrees, and alt
%   is the altitude of the coordinate in meters. These values are for the
%   WGS84 reference ellipsoid, a standard ellipsoid used by GPS data. The
%   road network origin is accessible via the GeoReference read-only
%   property of the drivingScenario object. By specifying these coordinates
%   as the origin in the latlon2local function, you can convert road
%   centers from geographic coordinates into a driving scenario's local
%   coordinates before using them as inputs to the road method.
%
%   Example
%   -------
%   % Create a new scenario
%   scenario = drivingScenario
% 
%   % add a straight road segment 25 m in length.
%   road(scenario, [0 0 0; 25 0 0]);
% 
%   % add a vehicle 
%   v = vehicle(scenario)
% 
%   % tell it to follow a trajectory along the road at 20 m/s.
%   smoothTrajectory(v,[v.RearOverhang 0 0; 25-v.Length+v.RearOverhang 0 0], 20)
% 
%   % add a plot for debug
%   plot(scenario)
% 
%   % Start the simulation loop
%   while advance(scenario)
%      fprintf('The vehicle is located at %.2f m at t=%.0f ms\n', v.Position(1), scenario.SimulationTime*1000)
%      pause(0.1)
%   end
%
%   See also birdsEyePlot, visionDetectionGenerator, radarDetectionGenerator,
%   drivingScenarioDesigner.

%   Copyright 2016-2022 The MathWorks, Inc.

    
    properties
        %SampleTime duration of time between updates
        %   specify SampleTime as the duration of time between subsequent
        %   updates of the scenario simulation.  The default value of
        %   SampleTime is 0.01
        SampleTime(1,1) {mustBeNumeric, mustBePositive, mustBeFinite} = 0.01
        
        %StopTime time at which to stop simulation
        %   specify StopTime as the time at which simulation must stop.
        %   The default value of StopTime is Inf (infinity).
        StopTime(1,1) {mustBeNumeric, mustBePositive} = Inf
    end
    
    properties (SetAccess = public)  % 为了动态改变场景中的Actors，将Actors的属性从protected改为public
        %SimulationTime current time of the simulation (read only)
        %   The current time of simulation.  To reset the time
        %   to zero, call the restart method.
        SimulationTime = 0
        %IsRunning true if the simulation is still running (read only)
        %   IsRunning indicates when the simulation is running.  Simulation
        %   runs until an actors has finished moving or the StopTime is
        %   reached, whichever comes first.  To re-enable a simulation
        %   call the reset method.
        IsRunning = true
        %Actors an array of actors and vehicles in the simulation (read only)
        %   Actors holds a heterogeneous array of all the actors and vehicles
        %   shown in simulation.  To add an actor, call the actor method.  
        %   To add a vehicle, call the vehicle method.  
        Actors  
        %Barriers an array of barriers in the simulation (read only)
        %   Barriers holds a heterogeneous array of all barriers
        %   shown in simulation.  To add a barrier, call the barrier method.   
        Barriers
        %ParkingLots an array of parking lots in the simulation (read only)
        %   Parking lots holds a heterogeneous array of all parking lots
        %   shown in simulation.  To add a parking lot, call the parkingLot method.   
        ParkingLots
    end
    
    properties (Hidden, Dependent, SetAccess = protected)
        %GeoReference geographic coordinate of the road network origin (read only)
        GeoReference
    end
    
    properties (Hidden, Transient, SetAccess = protected)
        Plots
        %CoordinateSystem CoordinateSystem Define the coordinate system 
        % used by the driving toolbox
        %   Support for two coordinate systems. ENU which is a Z-up
        %   and NED which a Z-down convention.
        %   Default is ENU
        % This will not change for a given scenario object
        AxesOrientation = 'ENU';        
    end
    
    properties (Hidden, Transient)
        % Disable updating the plotwaypoints call mutiple times
        EnablePlotUpdates = false;
        %AllowSharpCurvature Allow sharp curvature in driving scenario
        AllowSharpCurvature = true;
    end

    methods
        function obj = drivingScenario(varargin)
            try
                parseInputs(obj, varargin{:});
            catch ME
                throwAsCaller(ME);
            end
        end
        
        function set.AxesOrientation(this, orientation)
            try
                this.AxesOrientation = driving.scenario.internal.AxesOrientation.validate(orientation, 'drivingScenario');
            catch ME
                throwAsCaller(ME);
            end
        end
        
        function ref = get.GeoReference(this)
            ref = this.GeographicReference;
        end
        
    end
    
    methods (Access = protected)
        
        function group = getPropertyGroups(this)
            group = getPropertyGroups@matlab.mixin.CustomDisplay(this);
            
            % Add GeoReference to property list, if available
            if isscalar(this) && ~isempty(this.GeoReference)
                propList = group.PropertyList;
                propList.GeoReference = this.GeoReference;
                group = matlab.mixin.util.PropertyGroup(propList);
            end
        end
        
    end
    
    methods (Hidden)
        disconnectPlot(obj, hAxes)
        removeAllActors(obj)
        rrMap = getRoadRunnerHDMap(obj)
    end
end

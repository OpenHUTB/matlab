classdef Actor < driving.scenario.ActorBase
%driving.scenario.Actor 为驾驶场景创建参与者
%
%   driving.scenario.Actor contains properties and methods that govern
%   the pose, size, and radar-cross section of an actor object in a
%   driving scenario.
%   
%   See also drivingScenario/actor.

%   Copyright 2016-2020 The MathWorks, Inc.
    
    properties
        % 参与者生成的进入时间
        EntryTime {mustBeNumeric, double, mustBeFinite, mustBeNonnegative} = 0
        % 参与者消失的退出时间
        ExitTime {mustBeNumeric, double, mustBePositive} = Inf
    end

    properties (Hidden)
        MotionStrategy
        IsVisible (1,1) logical = true
        IsSpawnValid (1,1) logical = true
    end

    properties(Hidden, Transient)
        EnablePlotUpdates = false;
    end
    
    properties (Access = private, Hidden)
        ObjectPoses = [];
    end
    
    methods
        function obj = Actor(scenario, id, varargin)
           obj@driving.scenario.ActorBase(scenario, id, varargin{:});
           obj.MotionStrategy = driving.scenario.Stationary(obj);
           if isempty(obj.pPlotColor)
               obj.pPlotColor = obj.getDefaultColorForActorID(id);
           end
           isActorSpawnValid(obj);
        end
        
        function chasePlot(obj, varargin)
            %chasePlot(a, Name, Value, ...) adds an egocentric projective
            %    perspective plot seen from immediately behind the actor, a, with
            %    optional name-value pair arguments described below:
            %
            %       Parent         A handle to an axes object to contain the
            %                      plot. If not specified, a new figure is
            %                      generated.
            %
            %       Centerline     If 'on', then a centerline is painted in the
            %                      middle of all road segments.
            %                      Default: 'off'
            %
            %       RoadCenters    If 'on', then the road centers used to define
            %                      the roads are shown in the plot.
            %                      Default: 'off'
            %
            %       Waypoints      If 'on', then waypoints of the actors
            %                      are shown in the plot.
            %                      Default: 'off'
            %
            %       Meshes         If set to 'on', meshes of actors will be shown in
            %                      the plot instead of cuboids. Default: 'off'
            %
            %       ViewHeight     Defines the height (in meters) above the
            %                      bottom of the actor where the chase plot
            %                      is positioned.  The default height is 50%
            %                      higher than the actor's height.
            %
            %       ViewLocation   Location of the view's center specified as [x,y]
            %                      in the actor's coordinate system.  The default
            %                      location is positioned behind the actor's center
            %                      at 2.5 times the length of the actor.
            %
            %       ViewRoll       The orientation of the view, specified in the
            %       ViewPitch      actor's coordinate system.  The default roll,
            %       ViewYaw        pitch, and yaw angles are all zero (degrees).
            %
            %    Example
            %    -------
            %    s = drivingScenario
            %
            %    % construct a straight road segment 25 m in length.
            %    road(s, [0 0 0; 25 0 0]);
            %
            %    % add a pedestrian and a vehicle
            %    p = actor(s, 'Length', 0.2, 'Width', 0.4, 'Height', 1.7,'ClassID',4)
            %    v = vehicle(s,'ClassID',1)
            %
            %    % specify the pedestrian to follow a trajectory across the road at 2 m/s.
            %    smoothTrajectory(p,[15 -3 0; 15 3 0], 2)
            %
            %    % specify the vehicle to follow a trajectory along the road at 20 m/s.
            %    smoothTrajectory(v,[v.RearOverhang 0 0; 25-v.Length+v.RearOverhang 0 0], 20)
            %
            %    % make a figure and reset it.
            %    hFigure = figure(1);
            %    clf(hFigure,'reset');
            %
            %    % add a scenario plot
            %    hAxes = subplot(1,2,1);
            %    plot(s,'Parent',hAxes,'Centerline','on','Waypoints','on','RoadCenters','on')
            %    title('Scenario plot');
            %
            %    % add an egocentric plot for the vehicle
            %    hPanel = uipanel(hFigure,'Position',[.5 0 .5 1],'Units','Normal');
            %    chasePlot(v,'Parent',axes(hPanel),'Centerline','on','Waypoints','on','RoadCenters','on')
            %    title('Chase plot');
            %
            %    % Start the simulation loop
            %    while advance(s)
            %       pause(0.1)
            %    end
            %
            %   See also plot.
            plot(obj.Scenario, ...
                'EgoActor',obj, ...
                'ViewHeight', 3/2 * obj.Height, ...
                'ViewLocation', [-5/2 * obj.Length 0], ...
                'ViewRoll', 0, ...
                'ViewPitch', 0, ...
                'ViewYaw', 0, ...
                varargin{:});
        end
        
        function rbs = roadBoundaries(obj)
            % get boundaries in scenario coordinates
            rbs = roadBoundaries(obj.Scenario);

            % translate and rotate to world coordinates
            egoPos = obj.Position;
            R = scenarioToEgoRotator(obj);
            for i=1:numel(rbs)
                rbs{i} = (rbs{i}-egoPos) * R;
            end
        end
        
        function targetStruct = targetPoses(egoActor,varargin)
            %targetPoses Return pose information for all other actors
            %   poses = targetPoses(a) returns a struct array containing
            %   the ActorID, ClassID, Position, Velocity, Roll, Pitch, and
            %   Yaw of all other actors and objects in the actor's
            %   coordinate system.  The actor must be previously added to
            %   the driving scenario via the actor or vehicle methods.
            %
            %   poses = targetPoses(a, range) returns a struct array
            %   containing the ActorID, ClassID, Position, Velocity, Roll,
            %   Pitch, and Yaw of all other actors and objects that
            %   lie within a certain distance, specified by range. The actor
            %   must be previously added to the driving scenario via the
            %   actor or vehicle methods. Specify range in meters.
            %
            %   Example
            %   -------
            %   s = drivingScenario('SampleTime',0.1);
            %
            %   % construct a straight road segment 25 m in length.
            %   road(s, [0 0 0; 25 0 0]);
            %
            %   % add a pedestrian and a vehicle
            %   p = actor(s, 'Length', 0.2, 'Width', 0.4, 'Height', 1.7,'ClassID',4)
            %   v = vehicle(s,'ClassID',1)
            %
            %   % specify the pedestrian to cross the road at 2 m/s.
            %   smoothTrajectory(p,[15 -3 0; 15 3 0], 2)
            %
            %   % specify the vehicle to travel along the road at 20 m/s.
            %   smoothTrajectory(v,[v.RearOverhang 0 0; 25-v.Length+v.RearOverhang 0 0], 20)
            %
            %   % add an egocentric plot for the vehicle
            %   chasePlot(v,'Centerline','on')
            %
            %   % Start the simulation loop
            %   while advance(s)
            %      % get position of all other actors in the vehicle's coordinates.
            %      poses = targetPoses(v);
            %      p = poses(1).Position;
            %
            %      % display the position relative to the vehicle
            %      fprintf('The pedestrian''s location is at [%f %f]\n', p(1), p(2));
            %
            %      % allow plot to update
            %      pause(0.1);
            %   end
            %
            %   See also:  targetOutlines, actorPoses, actor, vehicle.
            
            % Validate egoVehicle
            if egoActor.EnablePlotUpdates
                validateEgoActor(egoActor);
            end                        
            
            % Prepopulate an empty structure to return if there are no
            % other actors.
            targetStruct = struct('ActorID', {}, ...
                'ClassID', {}, ...
                'Position', {}, ...
                'Velocity', {}, ...
                'Roll', {}, ...
                'Pitch', {}, ...
                'Yaw', {}, ...
                'AngularVelocity', {});
            flds = fieldnames(targetStruct);
            
            % Condition 1 - Return objects if range is specified or if sim is not running
            % Condition 2 - Get objects only once during sim
            cond1 = ~isempty(varargin) || ~egoActor.Scenario.IsRunning;
            cond2 = isempty(egoActor.ObjectPoses) && egoActor.Scenario.IsRunning;
            if (cond1 || cond2) && isa(egoActor.Scenario.Barriers, 'driving.scenario.Barrier')
                getObjects = true;
                allActors = getActorsInRange(egoActor, egoActor.Scenario, ...
                                             getObjects, varargin{:});
                targetActors = allActors.Actors;
                objects = allActors.Objects;
                
                % Erase existing object poses before repopulating
                egoActor.ObjectPoses = [];
                % Convert array of objects into a structure array
                for iObj = numel(objects):-1:1
                    thisObj = objects(iObj);
                    % Get encoded Actor ID
                    egoActor.ObjectPoses(iObj).ActorID = thisObj.getEncodedActorID();
                    for iFld = 2:numel(flds)
                        thisFld = flds{iFld};
                        egoActor.ObjectPoses(iObj).(thisFld) = thisObj.(thisFld);
                    end
                end
            else
                % Only get Actors
                getObjects = false;
                allActors = getActorsInRange(egoActor, egoActor.Scenario, ...
                                             getObjects, varargin{:});
                targetActors = allActors.Actors;
            end                      
            
            % Get visible target list
            visibleTargets = visibleActors(targetActors);
            targetActors = targetActors(visibleTargets);
            
            % Convert array of actor objects into a structure array
            for iTgt = numel(targetActors):-1:1
                thisTgt = targetActors(iTgt);
                for iFld = 1:numel(flds)
                    thisFld = flds{iFld};
                    targetStruct(iTgt).(thisFld) = thisTgt.(thisFld);
                end
            end
            
            targetStruct = [targetStruct egoActor.ObjectPoses];
            targetStruct = driving.scenario.targetsToEgo(targetStruct,egoActor);
        end
        
        function restart(obj)
            restart(obj.MotionStrategy);
            obj.ObjectPoses = [];
        end
       
        function trajectory(obj, waypoints, varargin)
            %trajectory Specify an actor's trajectory
            %   trajectory(a, waypoints) specifies a trajectory through N waypoints that
            %   a driving scenario actor, a, must follow at a constant speed of 30 m/s.
            %   Each of the N-1 segments between the waypoints defines a curve whose
            %   curvature varies linearly with length.  If the first and last waypoint
            %   are identical, then the path forms a loop.
            %   Specify waypoints as an N-by-3 matrix where each row corresponds to the
            %   [x,y,z] position of the actor.  The z position is interpolated via a
            %   shape preserving piecewise cubic curve.  If the waypoints are specified
            %   as an N-by-2 matrix, then the height information is assumed to be zero.
            %
            %   trajectory results in a piecewise constant-acceleration
            %   profile for each of the N - 1 segments, which have
            %   discontinuities between them. To avoid discontinuities in
            %   acceleration, use the smoothTrajectory method.
            %
            %   trajectory(a, waypoints, speed) specifies the speed of the
            %   actor through each waypoint.  If speed is a scalar value,
            %   then the actor traverses the waypoints with constant
            %   velocity.  If speed is an N-element vector, then the
            %   actor traverses through each waypoint at the corresponding
            %   speed moving between each point with constant acceleration.
            %   Specify negative speed for reverse motion. Positive speeds
            %   (forward motions) and negative speeds (reverse motions)
            %   must be separated by a waypoint with zero speed.
            %
            %   trajectory(a, waypoints, speed, waittime) additionally
            %   specifies the amount of time, in seconds, that the actor
            %   stops at each waypoint. waittime is a nonnegative vector of
            %   the same length as waypoints.
            %
            %   trajectory(_, Name, Value) specifies additional name-value 
            %   pair argument as described below:
            % 
            %       Yaw            Yaw of actor at each waypoint,
            %                      specified as an N-element vector, where
            %                      N is the number of waypoints. Units are
            %                      in degrees and angles are positive in
            %                      the counterclockwise direction. If you
            %                      do not specify 'Yaw', then the yaw at
            %                      each waypoint is NaN, meaning that the
            %                      yaw has no constraints.
            %  
            %   % Example 1: Define trajectory of a vehicle with waypoints and speed
            %   -------
            %   s = drivingScenario;
            %
            %   % construct a circular road
            %   road(s, [40 10; 50 20; 40 30; 30 20; 40 10]);
            %
            %   % create a car that is 3 meters in length.
            %   v = vehicle(s,'Length',3,'ClassID',1);
            %
            %   % drive the car at varying points and speeds along the circle.
            %   waypoints = [33,20; 32,12; 40,8; 46,13;50,22; 35,27];
            %   speeds = [5 0 10 5 9 0];
            %   trajectory(v, waypoints, speeds)
            %
            %   % plot and run simulation
            %   plot(s,'Centerline','on','Waypoints', 'on', 'RoadCenters','on')
            %   while advance(s)
            %       fprintf('The car is located at (%.2f,%.2f) m, with speed %.4f m/s at t=%.f ms\n', ...
            %           v.Position(1), v.Position(2), norm(v.Velocity), s.SimulationTime*1000)
            %       pause(0.01)
            %   end
            %
            %   % Example 2: Define trajectory of a vehicle with waypoints,
            %   % speed and waittime
            %   -------
            %
            %   s = drivingScenario;
            %
            %   % Add all road segments
            %   roadCenters = [140 0 0; 60 0 0];
            %   road(s, roadCenters);
            %
            %   roadCenters = [100 40 0; 100 -40 0];
            %   road(s, roadCenters);
            %
            %   % Add the ego vehicle
            %   egoVehicle = vehicle(s,'ClassID',1);
            %   waypoints = [64 -1.5 0;
            %     93 -1.5 0;
            %     106 -1.5 0;
            %     136 -1.5 0];
            %   speed = [12;0;10;10];
            %   waittime = [0;3;0;0];
            %   trajectory(egoVehicle, waypoints, speed, waittime);
            %
            %   % Add the non-ego actor
            %   car1 = vehicle(s,'ClassID',1);
            %   waypoints = [98.5 34 0;
            %     98.5 5.9 0;
            %     98.5 -6.8 0;
            %     98.5 -34 0];
            %   speed = 5;
            %   trajectory(car1, waypoints, speed);
            %
            %   plot(s,'Centerline','on','Waypoints', 'on', 'RoadCenters','on')
            %   while advance(s)
            %        fprintf('The egoVehicle is located at (%.2f,%.2f) m, with speed %.2f m/s at t=%.f ms\n', ...
            %           egoVehicle.Position(1), egoVehicle.Position(2), norm(egoVehicle.Velocity), s.SimulationTime*1000)
            %       pause(0.01)
            %   end
            %
            %   % Example 3: Define trajectory with reverse motion
            %   -------
            %   s = drivingScenario;
            %   % Add all road segments
            %   roadCenters = [12 0 0;
            %       18 0 0];
            %   lmSolidWhite = laneMarking('Solid');
            %   marking = [laneMarking('Solid', 'Color', [0.98 0.86 0.36])
            %       repmat(lmSolidWhite,6,1)];
            %   laneSpecification = lanespec(6, 'Width', 3, 'Marking', marking);
            %   road(s, roadCenters, 'Lanes', laneSpecification);
            %   roadCenters = [-1 0 0;
            %       6 0 0];
            %   road(s, roadCenters, 'Lanes', laneSpecification);
            %   roadCenters = [6 0 0;
            %       12 0 0];
            %   laneSpecification = lanespec(1, 'Width', 18);
            %   road(s, roadCenters, 'Lanes', laneSpecification);
            %
            %   % Add the ego vehicle
            %   egoVehicle = vehicle(s, ...
            %       'ClassID', 1, ...
            %       'Width', 2, ...
            %       'Position', [10 -10 0.01], ...
            %       'Name', 'Car');
            %   % Define trajectory
            %   waypoints = [10 -10 0.01;
            %       9.9 4.6 0;
            %       9.9 0.6 0;
            %       8.9 -1.4 0;
            %       7.7 -1.6 0;
            %       0.3 -1.6 0];
            %   speed = [6.7;0;-6.7;-5;-3;0];
            %   trajectory(egoVehicle, waypoints, speed);
            %
            %   plot(s,'Waypoints','on');
            %   while advance(s)
            %       pause(0.001);
            %   end
            %
            %   Example 4: Define trajectory of a pedestrian with waypoints,
            %   speed, wait time, and yaw
            %   -------
            %   s = drivingScenario;
            %
            %   % Add all road segments
            %   roadCenters = [0 10.06 0;
            %       0 -10.57 0];
            %   road(s, roadCenters, 'Name', 'Road');
            % 
            %   roadCenters = [10.03 0 0;
            %       -12.3 0 0];
            %   road(s, roadCenters, 'Name', 'Road1');
            % 
            %   % Add the actors
            %   pedestrian = actor(s, ...
            %       'ClassID', 4, ...
            %       'Length', 0.24, ...
            %       'Width', 0.45, ...
            %       'Height', 1.7, ...
            %       'Position', [-11 -0.25 0], ...
            %       'RCSPattern', [-8 -8;-8 -8], ...
            %       'Mesh', driving.scenario.pedestrianMesh, ...
            %       'Name', 'Pedestrian');
            %   waypoints = [-11 -0.25 0;
            %       -1 -0.25 0;
            %       -0.6 -0.4 0;
            %       -0.6 -9.3 0];
            %   speed = [1.5;0;0.5;1.5];
            %   yaw =  [0;0;-90;-90];
            %   waittime = [0;0.2;0;0];
            %   trajectory(pedestrian, waypoints, speed, waittime, 'Yaw', yaw);
            %   
            %   plot(s,'Waypoints','on');
            %   while advance(s)
            %       pause(0.001);
            %   end
            %
            %   See also smoothTrajectory, actor, vehicle, road.
            
            p = inputParser;
            validateFcnWaypoints = @(x) validateattributes(x,{'numeric'},{'real','2d','finite'},'trajectory','waypoints');
            validateFcnSpeed = @(x) validateattributes(x,{'numeric'},{'real','vector','finite'},'trajectory','speed');
            validateFcnWaitTime = @(x) validateattributes(x,{'numeric'},{'real','nonnegative','vector','finite'},'trajectory','waitime');
            validateFcnYaw = @(x) validateattributes(x,{'numeric'},{'vector','real'},'trajectory','Yaw');
            
            addRequired(p,'Waypoints',validateFcnWaypoints);
            addOptional(p,'Speed',[],validateFcnSpeed);
            addOptional(p,'WaitTime',[],validateFcnWaitTime);
            addParameter(p,'Yaw',[],validateFcnYaw);
            
            parse(p,waypoints,varargin{:});
            
            obj.MotionStrategy = driving.scenario.Path(obj, p.Results);
            updatePlots(obj);
        end

        function path(obj, waypoints, varargin)
            trajectory(obj, waypoints, varargin{:});
        end
        
        function [position, yaw, length, width, originOffset, color, varargout] = targetOutlines(obj, type)
            %targetOutlines Return rectangular outlines relative to a specific actor
            %   [position, yaw, length, width, originOffset, color] =
            %   targetOutlines(a) returns the two-dimensional rectangular
            %   outlines of each actor and barrier in the scenario,
            %   positioned in the coordinate system of the specified actor, a.
            %   [position, yaw, length, width, originOffset, color,
            %   numBarrierSegments] = targetOutlines(a, 'Barriers') returns
            %   the two-dimensional rectangular outlines of just barriers
            %   in the scenario, with an additional output of the number of
            %   segments in each barrier.                     
            %   These outlines can be used as arguments to an
            %   outlinePlotter when using a birdsEyePlot.  For a scenario
            %   with N actors, the output arguments are described below:
            %
            %   position           - an N-by-2 matrix, where each row contains the
            %                        x- and y- coordinates of the (rotational)
            %                        center of the rectangle.
            %
            %   yaw                - an N-element vector containing the yaw of each actor
            %                        specified in degrees measured in a counter-clockwise
            %                        direction as seen from above.
            %
            %   length             - an N-element vector containing the length of each
            %                        outline.
            %
            %   width              - an N-element vector containing the width of each
            %                        outline.
            %
            %   originOffset       - an N-by-2 matrix, where each row defines an offset
            %                        applied to the geometric center of the rectangle
            %                        that defines the rotational center of the rectangle.
            %                        Vehicles typically define this offset so that the
            %                        rotational center rests directly beneath the rear
            %                        axle of the vehicle.
            %
            %   color              - an N-by-3 matrix, where each row defines the [R,G,B]
            %                        values that are used in driving scenario plots
            %                        corresponding to the respective actor.
            %
            %   numBarrierSegments - an N-element vector containing the number of segments
            %                        in each barrier in the scenario. This output is returned
            %                        only when the 'Barriers' flag is provided as input.                      
            %
            %   Example
            %   -------
            %   s = drivingScenario;
            %
            %   % construct a straight road segment 25 m in length.
            %   road(s, [0 0 0; 25 0 0]);
            %
            %   % add a pedestrian and a vehicle
            %   p = actor(s, 'Length', 0.2, 'Width', 0.4, 'Height', 1.7,'ClassID',4)
            %   v = vehicle(s,'ClassID',1)
            %
            %   % specify the pedestrian to cross the road at 1 m/s.
            %   smoothTrajectory(p,[15 -3 0; 15 3 0], 1);
            %
            %   % specify the vehicle to follow the road at 10 m/s.
            %   smoothTrajectory(v,[v.RearOverhang 0 0; 25-v.Length+v.RearOverhang 0 0], 10);
            %
            %   % add an egocentric plot for the vehicle
            %   chasePlot(v,'Centerline','on')
            %
            %   % create a bird's-eye plot
            %   bep = birdsEyePlot('XLim',[-25 25],'YLim',[-10 10]);
            %   olPlotter = outlinePlotter(bep);
            %   lbPlotter = laneBoundaryPlotter(bep);
            %   legend('off');
            %
            %   % start the simulation loop
            %   while advance(s)
            %      % get the road boundaries and rectangular outlines
            %      rb = roadBoundaries(v);
            %      [position, yaw, length, width, originOffset, color] = targetOutlines(v);
            %
            %      % update the bird's-eye plotters with the road and actors
            %      plotLaneBoundary(lbPlotter, rb);
            %      plotOutline(olPlotter, position, yaw, length, width, ...
            %                  'OriginOffset', originOffset, 'Color', color);
            %
            %      % allow time for plot to update
            %      pause(0.01)
            %   end
            %
            %   See also:  targetMeshes, targetPoses, actorPoses, actor, vehicle.
            if nargin < 2
                type = '';
            end           
            s = obj.Scenario;
            aprof = actorProfiles(s);
            aposes = egoAndTargetPoses(obj);
            visibleTargets = visibleActors(s.Actors);
            aprof(~visibleTargets) = [];        % Remove targets that are not visible
            aposes(~visibleTargets) = [];       % Remove targets that are not visible
            length = [aprof(:).Length]';
            width = [aprof(:).Width]';
            yaw = [aposes(:).Yaw]';
            position = reshape([aposes(:).Position],3,[])';
            position = position(:,1:2);
            originOffset = reshape([aprof(:).OriginOffset],3,[])';
            originOffset = originOffset(:,1:2);            
            if strcmp(type, 'Barriers')
                numActors = numel(visibleTargets(visibleTargets == 1));
                position = position(numActors+1:end, :);
                length = length(numActors+1:end, :);
                width = width(numActors+1:end, :);
                yaw = yaw(numActors+1:end, :);
                originOffset = originOffset(numActors+1:end, :);
                color = getBarrierColors(s,[]);
                varargout{1} = arrayfun(@(x) numel(x.BarrierSegments), s.Barriers)';
            else
                numActors = numel(visibleTargets(visibleTargets == 1));
                position = position(1:numActors, :);
                length = length(1:numActors, :);
                width = width(1:numActors, :);
                yaw = yaw(1:numActors, :);
                originOffset = originOffset(1:numActors, :);
                color = vertcat(s.Actors.PlotColor);
                color = color(visibleTargets,:);  
            end
        end 
        
        function [vertices, faces, colors] = targetMeshes(obj,orientation)
            %targetMeshes Return mesh vertices and faces relative to a specific actor
            %   [vertices, faces, color] = targetMeshes(a) returns the mesh
            %   vertices and faces of each actor positioned in the
            %   coordinate system of the specified actor, a. When using a
            %   birdsEyePlot with a meshPlotter, you use these meshes as
            %   arguments to the plotMesh function. For a scenario with N
            %   actors, the output arguments are described below:
            %
            %      vertices      - Cell array of mesh vertices for each
            %                      actor. Each element in vertices must be
            %                      a V-by-3 real-valued matrix of vertices,
            %                      where each row defines a point in 3-D
            %                      (x,y,z) space.
            %
            %      faces         - Cell array of mesh faces for each
            %                      actor. Each element in faces must be an
            %                      F-by-3 matrix of integers, where F is
            %                      the number of faces and each row defines
            %                      a triangle of vertex IDs that make up
            %                      the face. The vertex IDs correspond to
            %                      the row numbers of vertices.
            %
            %      colors        - an N-by-3 matrix, where each row defines the [R,G,B]
            %                      values that are used in driving scenario plots
            %                      corresponding to the respective actor.
            %
            %   Example
            %   -------
            %   s = drivingScenario;
            %   
            %   % construct a straight road segment 25 m in length.
            %   road(s, [0 0 0; 25 0 0]);
            %   
            %   % add a pedestrian and a vehicle
            %   p = actor(s, 'Length', 0.2, 'Width', 0.4, 'Height', 1.7, 'Mesh', driving.scenario.pedestrianMesh);
            %   v = vehicle(s, 'Mesh', driving.scenario.carMesh);
            %   
            %   % specify the pedestrian to cross the road at 1 m/s.
            %   smoothTrajectory(p,[15 -3 0; 15 3 0], 1);
            %
            %   % specify the vehicle to follow the road at 10 m/s.
            %   smoothTrajectory(v,[v.RearOverhang 0 0; 25-v.Length+v.RearOverhang 0 0], 10);
            %   
            %   % add an egocentric plot for the vehicle
            %   chasePlot(v,'Centerline','on','Meshes','on')
            %
            %   % create a bird's-eye plot
            %   bep = birdsEyePlot('XLim',[-25 25],'YLim',[-10 10]);
            %   mPlotter = meshPlotter(bep);
            %   lbPlotter = laneBoundaryPlotter(bep);
            %   legend('off');
            %
            %   % start the simulation loop
            %   while advance(s)
            %      % get the road boundaries and meshes
            %      rb = roadBoundaries(v);
            %      [vertices, faces, colors] = targetMeshes(v);
            %
            %      % update the bird's-eye plotters with the road boundaries and actor meshes
            %      plotLaneBoundary(lbPlotter, rb);
            %      plotMesh(mPlotter, vertices, faces, 'Color', colors);
            %
            %      % allow time for plot to update
            %      pause(0.01)
            %   end
            %
            %   See also:  targetOutlines, targetPoses, actorPoses, actor, vehicle.
            s = obj.Scenario;
            visibleTargets = visibleActors(s.Actors);
            actors = s.Actors(visibleTargets);
            numActors = length(actors);
            vertices = cell(numActors,1);
            faces = cell(numActors,1);
            if nargin < 2
                orientation = 'ENU';
            else
                orientation = validatestring(orientation,{'ENU','NED'},'targetMeshes','orientation',2);
            end
            egoPos = obj.Position;
            R = scenarioToEgoRotator(obj);
            for kndx = 1:length(actors)
                [v, faces{kndx}] = scenarioFacesMeshes(actors(kndx), orientation);
                % Translate to the ego
                v = (v-egoPos) * R;
                vertices{kndx} = v;
            end
            colors = vertcat(s.Actors.PlotColor);
            % fetch target color list
            colors = colors(visibleTargets,:);
        end
        
        function [lmv, lmf] = laneMarkingVertices(obj)
            % Return vertices of lane markings in scenario coordinates
            [lmv,lmf] = laneMarkingVertices(obj.Scenario);
            if ~isempty(lmv)
                % translate and rotate to world coordinates
                egoPos = obj.Position;
                R = scenarioToEgoRotator(obj);
                lmv = (lmv-egoPos) * R;
            end
        end
        
        function [plmv, plmf] = parkingLaneMarkingVertices(obj)
            % Return vertices of parking lane markings in scenario coordinates
            [plmv,plmf] = parkingLaneMarkingVertices(obj.Scenario);
            if ~isempty(plmv)
                % translate and rotate to world coordinates
                egoPos = obj.Position;
                R = scenarioToEgoRotator(obj);
                plmv = (plmv-egoPos) * R;
            end
        end
        
        function [currentLane, numLanes] = currentLane(obj)
            %[cl, numLanes] = currentLane(a) returns the current lane (cl) of the
            %   actor a. Number of lanes (numLanes) for the road the actor is on can
            %   also be returned. Lanes are numbered from left to right relative to the
            %   actor starting from 1. When the actor is not on a road or is on a road
            %   without any lanes specified, empty values are returned.
            %
            %   % Example
            %   % -------
            %   s = drivingScenario;
            %
            %   % Create a straight road with lanes
            %   roadCenters = [0 0; 80 0];
            %   road(s,roadCenters,'Lanes',lanespec([1 2],'Width',3));
            %
            %   % Add the ego car with a trajectory
            %   v = vehicle(s,'Position',[5 0 0],'Length',3,'Width',2,'Height',1.6,'ClassID',1);
            %   smoothTrajectory(v,[1 0 0; 20 0 0; 30 0 0;50 0 0], 20);
            %
            %   % Plot
            %   plot(s);
            %
            %   % Simulate
            %   while advance(s)
            %       cl = currentLane(v);
            %   end
            %
            %   See also actor, laneBoundaries.
            rt = closestRoadTile(obj.Scenario, obj.Position);
            [currentLane,numLanes] = getCurrentLane(obj,rt);
        end
        
        function lb = laneBoundaries(obj,varargin)
            %lb = laneBoundaries(a, Name, Value, ...) returns lane boundaries as an
            %   array of structures of the actor a. By default, only the left and right
            %   lane boundaries of the actor are returned. The structure contains the
            %   computed boundary coordinates, curvature, curvature derivative, heading
            %   angle, lateral offset, boundary type, strength, and width. Optional
            %   name-value pair arguments are described below:
            %
            %     XDistance     An array of distances in meters from the actor position
            %                   along the X-direction for determining the lane
            %                   boundaries. Default value is 0. Lane boundary at actor
            %                   position, 0, is always returned.
            %
            %     LocationType  Specify if the boundaries returned are located on the
            %                   center of the lane markings or the inner edges of the
            %                   lane markings. Default value is 'center'.
            %
            %     AllBoundaries Specify true if all the lane boundaries from left to
            %                   right relative to the actor should be returned. The
            %                   default value is false and only the left and right lane
            %                   boundaries are returned.
            %
            %   % Example
            %   % -------
            %   s = drivingScenario;
            %
            %   % Create a simplistic s curve
            %   roadCenters = [-35 20 0; -20 -20 0; 0 0 0; 20 20 0; 35 -20 0];
            %
            %   % Specify the lanes
            %   lm = [laneMarking('Solid','Color','y'); laneMarking('Dashed');
            %     laneMarking('Dashed'); laneMarking('Solid')];
            %   ls = lanespec(3,'Marking',lm);
            %
            %   % Create a road with lanes
            %   road(s, roadCenters,'Lanes',ls);
            %
            %   % Add the ego car with a trajectory
            %   v = vehicle(s, ...
            %     'ClassID', 1, ...
            %     'Position', [-35 20 0]);
            %   waypoints = [-35 20 0; -20 -20 0; 0 0 0; 20 20 0; 35 -20 0];
            %   speed = 30;
            %   smoothTrajectory(v, waypoints, speed);
            %
            %   % Plots
            %   plot(s);
            %   chasePlot(v);
            %
            %   % Create a bird's-eye plot
            %   bep = birdsEyePlot('XLim',[-40 40],'YLim',[-30 30]);
            %   olPlotter = outlinePlotter(bep);
            %   % Left lane boundary plotter
            %   lbPlotter = laneBoundaryPlotter(bep,'Color','r','LineStyle','-');
            %   % Right lane boundary plotter
            %   rbPlotter = laneBoundaryPlotter(bep,'Color','g','LineStyle','-');
            %   % Road boundary plotter
            %   rbsEdgePlotter = laneBoundaryPlotter(bep);
            %   legend('off');
            %
            %   % Simulate
            %   while advance(s)
            %     % Get the road boundaries and rectangular outlines
            %     rbs = roadBoundaries(v);
            %     [position, yaw, length, width, originOffset, color] = targetOutlines(v);
            %     % Get the lane boundaries to the left and right of the vehicle
            %     lb = laneBoundaries(v,'XDistance',0:0.5:9.5);
            %     % update the bird's-eye plotters
            %     plotLaneBoundary(rbsEdgePlotter,rbs);
            %     plotLaneBoundary(lbPlotter, {lb(1).Coordinates});
            %     plotLaneBoundary(rbPlotter, {lb(2).Coordinates});
            %     plotOutline(olPlotter, position, yaw, length, width, ...
            %       'OriginOffset', originOffset, 'Color', color);
            %   end
            %
            %   See also actor, currentLane.
            rt = closestRoadTile(obj.Scenario, obj.Position);
            lb = getLaneBoundaries(obj,rt,varargin{:});
        end
        
         function set.EntryTime(obj,enttime)
            validateActorEntryTime(obj, enttime);
            obj.EntryTime = enttime;
            updateTrajectory(obj);
            if obj.EntryTime > 0
                obj.EnablePlotUpdates = true; %#ok<MCSUP>
            end
            if ~isempty(obj.Scenario)
                if any(obj.EntryTime(1) >= obj.Scenario.StopTime)
                    %Displaying warning message when EntryTime exceeds
                    %StopTime, Spawning do not happen.
                    warning(message('driving:scenario:EntryTimeExceedsStopTime'));
                end
            end
        end

        function set.ExitTime(obj,exttime)
            validateActorExitTime(obj, exttime);
            obj.ExitTime = exttime;
            updateTrajectory(obj);
            if obj.ExitTime < Inf
                obj.EnablePlotUpdates = true; %#ok<MCSUP>
            end
            if ~isempty(obj.Scenario)
                if ~isinf(obj.ExitTime(1)) && any(obj.ExitTime(1) > obj.Scenario.StopTime)
                    %Displaying warning message when ExitTime exceeds
                    %StopTime, Disappear do not happen.
                    warning(message('driving:scenario:ExitTimeExceedsStopTime'));
                end
            end
        end

        function mesh = roadMesh(obj,maxRadius)
            %roadMesh Returns a mesh representation of the actor's nearest roads
            %   mesh = roadMesh(a,maxRadius) returns an
            %   extendedObjectMesh of the actor's nearest roads. By default,
            %   roads within a radius of 120m from the actor are returned.
            %   Optionally, the second input argument maxRadius can be used
            %   to specify the radius. The maximum value that can be
            %   specified for radius is 500m.
            %
            %   Example
            %   -------
            %   % Generate point cloud for a car in driving scenario
            %   scenario = drivingScenario;
            %   roadCenters = [0 0; 50 0];
            %   road(scenario, roadCenters, 'lanes', lanespec([1 2]));
            %   roadCenters = [25 -25; 25  25];
            %   road(scenario, roadCenters, 'lanes', lanespec([1 1]));
            % 
            %   % Create cars and apply a car mesh
            %   mesh = driving.scenario.carMesh;
            %   egoVehicle = vehicle(scenario,'ClassID',1,'Mesh',mesh);
            %   smoothTrajectory(egoVehicle,[1 -2 0; 45 -2 0], 20);
            %   car = vehicle(scenario,'Position',[15 3 0],'Yaw',180,'ClassID',1,'Mesh',mesh);
            % 
            %   % Plot the road mesh
            %   rdmesh = roadMesh(egoVehicle);
            %   show(rdmesh);
            %
            %   % Plot the scenario
            %   plot(scenario, 'Meshes', 'on');
            % 
            %   % Plot lidar point cloud
            %   lidar = lidarPointCloudGenerator;
            %   lidar.ActorProfiles = actorProfiles(scenario);
            %   player = pcplayer([-20 20],[-10 10],[0 4]);
            %   scenario.StopTime = 1.5;
            %   while advance(scenario)
            %       tgts = targetPoses(egoVehicle);
            %       rdmesh = roadMesh(egoVehicle);
            %       [ptCloud,isValidTime] = lidar(tgts,rdmesh,scenario.SimulationTime);
            %       if isValidTime
            %           view(player,ptCloud);
            %       end
            %   end
            % 
            %   See also extendedObjectMesh, lidarPointCloudGenerator.
            if nargin < 2
                maxRadius = 120;
            else
                validateattributes(maxRadius,{'numeric'},{'real','positive','scalar','finite','<=',500},'roadMesh','maxRadius');
            end
            mesh = getRoadMesh(obj,maxRadius);
        end
        
        function smoothTrajectory(obj, waypoints, varargin)
            %smoothTrajectory Specify jerk-limited actor trajectory
            %   smoothTrajectory(a, waypoints) specifies a trajectory through N waypoints that
            %   a driving scenario actor, a, must follow at a constant speed of 30 m/s.
            %   Each of the N - 1 segments between the waypoints defines a curve whose
            %   curvature varies linearly with length. If the first and last waypoint
            %   are identical, then the path forms a loop.
            %   Specify waypoints as an N-by-3 matrix where each row corresponds to the
            %   [x,y,z] position of the actor. The z position is interpolated via a
            %   shape-preserving piecewise cubic curve. If you specify waypoints 
            %   as an N-by-2 matrix, then the height information is assumed to be zero.
            %
            %   smoothTrajectory creates a jerk-limited trajectory using a
            %   trapezoid acceleration profile that results in a smoother
            %   transition of accelerations. Each of the N - 1 segments
            %   consists of an initial constant jerk phase, a constant
            %   acceleration phase, and a final constant jerk phase. If
            %   smoothTrajectory is unable to find a jerk-limited
            %   trajectory given the input parameters, it throws an error.
            %   To achieve a feasible trajectory, try adjusting the
            %   waypoints, speed, and jerk parameters.
            %
            %   smoothTrajectory(a, waypoints, speed) specifies the speed of the
            %   actor through each waypoint. If speed is a scalar value,
            %   then the actor traverses the waypoints with constant
            %   velocity. If speed is an N-element vector, then the actor
            %   traverses each waypoint at the corresponding speed, moving
            %   between each point with a trapezoid acceleration profile.
            %   Specify negative speed for reverse motion. Positive speeds
            %   (forward motions) and negative speeds (reverse motions)
            %   must be separated by a waypoint with zero speed.
            %
            %   smoothTrajectory(a, waypoints, speed, waittime) additionally
            %   specifies the amount of time, in seconds, that the actor
            %   stops at each waypoint. waittime is a nonnegative vector of
            %   the same length as waypoints.
            %
            %   smoothTrajectory(_, Name, Value) specifies additional name-value 
            %   pair argument as described below:
            % 
            %       Yaw            Yaw of actor at each waypoint,
            %                      specified as an N-element vector, where
            %                      N is the number of waypoints. Units are
            %                      in degrees and angles are positive in
            %                      the counterclockwise direction. If you
            %                      do not specify 'Yaw', then the yaw at
            %                      each waypoint is NaN, meaning that the
            %                      yaw has no constraints.
            %
            %       Jerk           Specify maximum jerk for the constant
            %                      jerk phase of each of the N - 1 segments.
            %                      Default value is 0.6 m/s^3.
            %  
            %   % Example 1: Define smoothTrajectory of a vehicle with waypoints and speed
            %   -------
            %   % Create a driving scenario containing a circular road.
            %   s = drivingScenario;
            %   road(s, [40 10; 50 20; 40 30; 30 20; 40 10]);
            %
            %   % Create a car that is 3 meters in length.
            %   v = vehicle(s,'Length',3,'ClassID',1);
            %
            %   % Drive the car at varying points and speeds along the circle.
            %   waypoints = [33,20; 32,12; 40,8; 46,13;50,22; 35,27];
            %   speeds = [2 0 3 4 5 0];
            %   smoothTrajectory(v, waypoints, speeds)
            %
            %   % Plot and simulate the scenario.
            %   plot(s,'Centerline','on','Waypoints', 'on', 'RoadCenters','on')
            %   while advance(s)
            %       fprintf('The car is located at (%.2f,%.2f) m, with speed %.4f m/s at t=%.f ms\n', ...
            %           v.Position(1), v.Position(2), norm(v.Velocity), s.SimulationTime*1000)
            %       pause(0.01)
            %   end
            %
            %   % Example 2: Define smoothTrajectory of a vehicle with waypoints,
            %   % speed, and waittime
            %   -------
            %   % Create a driving scenario and add all road segments.
            %   s = drivingScenario;
            %
            %   roadCenters = [140 0 0; 60 0 0];
            %   road(s, roadCenters);
            %
            %   roadCenters = [100 40 0; 100 -40 0];
            %   road(s, roadCenters);
            %
            %   % Add the ego vehicle.
            %   egoVehicle = vehicle(s,'ClassID',1);
            %   waypoints = [64 -1.5 0;
            %     93 -1.5 0;
            %     106 -1.5 0;
            %     136 -1.5 0];
            %   speed = [3;0;3;3];
            %   waittime = [0;3;0;0];
            %   smoothTrajectory(egoVehicle, waypoints, speed, waittime);
            %
            %   % Add the non-ego actor.
            %   car1 = vehicle(s,'ClassID',1);
            %   waypoints = [98.5 34 0;
            %     98.5 5.9 0;
            %     98.5 -6.8 0;
            %     98.5 -34 0];
            %   speed = 2;
            %   smoothTrajectory(car1, waypoints, speed);
            %
            %   % Plot and simulate the scenario.
            %   plot(s,'Centerline','on','Waypoints', 'on', 'RoadCenters','on')
            %   while advance(s)
            %        fprintf('The egoVehicle is located at (%.2f,%.2f) m, with speed %.2f m/s at t=%.f ms\n', ...
            %           egoVehicle.Position(1), egoVehicle.Position(2), norm(egoVehicle.Velocity), s.SimulationTime*1000)
            %       pause(0.01)
            %   end
            %
            %   % Example 3: Define smoothTrajectory with reverse motion
            %   -------
            %   % Create a driving scenario and add all road segments.
            %   s = drivingScenario;
            %   roadCenters = [12 0 0; 18 0 0];
            %   lmSolidWhite = laneMarking('Solid');
            %   marking = [laneMarking('Solid', 'Color', [0.98 0.86 0.36])
            %       repmat(lmSolidWhite,6,1)];
            %   laneSpecification = lanespec(6, 'Width', 3, 'Marking', marking);
            %   road(s, roadCenters, 'Lanes', laneSpecification);
            %   roadCenters = [-1 0 0; 6 0 0];
            %   road(s, roadCenters, 'Lanes', laneSpecification);
            %   roadCenters = [6 0 0; 12 0 0];
            %   laneSpecification = lanespec(1, 'Width', 18);
            %   road(s, roadCenters, 'Lanes', laneSpecification);
            %
            %   % Add the ego vehicle
            %   egoVehicle = vehicle(s, ...
            %       'ClassID', 1, ...
            %       'Width', 2, ...
            %       'Position', [10 -10 0.01], ...
            %       'Name', 'Car');
            %
            %   % Define smoothTrajectory
            %   waypoints = [10 -10 0.01;
            %       9.9 4.6 0;
            %       9.9 0.6 0;
            %       8.9 -1.4 0;
            %       7.7 -1.6 0;
            %       0.3 -1.6 0];
            %   speed = [3;0;-0.5;-0.5;-0.5;0];
            %   smoothTrajectory(egoVehicle, waypoints, speed);
            %
            %   % Plot and simulate the scenario.
            %   plot(s,'Waypoints','on');
            %   while advance(s)
            %       pause(0.001);
            %   end
            %
            %   Example 4: Define smoothTrajectory of a pedestrian with waypoints,
            %   speed, waittime, and yaw
            %   -------
            %   % Create a driving scenario and add all road segments.
            %   s = drivingScenario;
            %
            %   roadCenters = [0 10.06 0; 0 -10.57 0];
            %   road(s, roadCenters, 'Name', 'Road');
            % 
            %   roadCenters = [10.03 0 0; -12.3 0 0];
            %   road(s, roadCenters, 'Name', 'Road1');
            % 
            %   % Add the actors.
            %   pedestrian = actor(s, ...
            %       'ClassID', 4, ...
            %       'Length', 0.24, ...
            %       'Width', 0.45, ...
            %       'Height', 1.7, ...
            %       'Position', [-11 -0.25 0], ...
            %       'RCSPattern', [-8 -8;-8 -8], ...
            %       'Mesh', driving.scenario.pedestrianMesh, ...
            %       'Name', 'Pedestrian');
            %   waypoints = [-11 -0.25 0;
            %       -1 -0.25 0;
            %       -0.6 -0.4 0;
            %       -0.6 -9.3 0];
            %   speed = [1.5;0;0.5;1.5];
            %   yaw =  [0;0;-90;-90];
            %   waittime = [0;0.2;0;0];
            %   smoothTrajectory(pedestrian, waypoints, speed, waittime, 'Yaw', yaw);
            %   
            %   % Plot and simulate the scenario.
            %   plot(s,'Waypoints','on');
            %   while advance(s)
            %       pause(0.001);
            %   end
            %
            %   See also actor, vehicle, road, state.
            
            p = inputParser;
            validateFcnWaypoints = @(x) validateattributes(x,{'numeric'},{'real','2d','finite'},'smoothTrajectory','waypoints');
            validateFcnSpeed = @(x) validateattributes(x,{'numeric'},{'real','vector','finite'},'smoothTrajectory','speed');
            validateFcnWaitTime = @(x) validateattributes(x,{'numeric'},{'real','nonnegative','vector','finite'},'smoothTrajectory','waitime');
            validateFcnYaw = @(x) validateattributes(x,{'numeric'},{'vector','real'},'smoothTrajectory','Yaw');
            validateFcnJerk = @(x) validateattributes(x,{'numeric'},{'scalar','real','finite','>=',0.1},'smoothTrajectory','Jerk');
            
            addRequired(p,'Waypoints',validateFcnWaypoints);
            addOptional(p,'Speed',[],validateFcnSpeed);
            addOptional(p,'WaitTime',[],validateFcnWaitTime);
            addParameter(p,'Yaw',[],validateFcnYaw);
            addParameter(p,'Jerk',0.6,validateFcnJerk);
            
            parse(p,waypoints,varargin{:});
            
            obj.MotionStrategy = driving.scenario.SmoothTrajectory(obj, p.Results, p.Results.Jerk);
            updatePlots(obj);
        end
        
        function gTruth = state(obj,varargin)
             %STATE Return state information of actor
             % gTruth = state(a) returns a struct containing the
             % Position, Velocity, Orientation, AngularVelocity, and
             % Acceleration of an actor in the world coordinate system.
             %
             % The state method is supported only for actor trajectories
             % created using the smoothTrajectory method, not the
             % trajectory method.
             %
             % Use state to output ground truth data required for an INS
             % sensor.
             %
             %   % Example 1: Simulate driving scenario with an INS sensor
             %   -------
             %   % Load data for a driving route.
             %   data = load('geoRoute.mat');
             %   latIn = data.latitude;
             %   lonIn = data.longitude;
             %
             %   % Convert route to Cartesian coordinates.
             %   alt = 10;  % 10 meters is an approximate altitude in Boston, MA
             %   origin = [latIn(1), lonIn(1), alt];
             %   numPoints = 20;
             %   [xEast, yNorth, zUp] = latlon2local(data.latitude(1:numPoints), data.longitude(1:numPoints), alt, origin);
             %
             %   % Create a driving scenario.
             %   s = drivingScenario('GeoReference', origin);
             %
             %   % Create a road.
             %   roadCenters = [xEast, yNorth, zUp];
             %   road(s,roadCenters);
             %
             %   % Create a vehicle that will follow the center lane.
             %   egoV = vehicle(s, 'ClassID',1);
             %   egoPath = roadCenters;
             %   egoSpeed = 30;
             %   % Create a smooth trajectory to avoid discontinuities in acceleration
             %   smoothTrajectory(egoV, egoPath, egoSpeed);
             %
             %   % Plot the scenario.
             %   plot(s);
             %
             %   % Show a 3-D view from behind the ego vehicle.
             %   chasePlot(egoV)
             %
             %   % Create an INS sensor.
             %   sensor = insSensor('TimeInput',true);
             %
             %   % Initialize a geographic player that displays last 10 positions.
             %   zoomLevel = 16;
             %   player = geoplayer(latIn(1), lonIn(1), zoomLevel, 'HistoryDepth', 10, 'HistoryStyle', 'line');
             %   indx = 2;
             %   while advance(s)
             %       % Obtain ground truth information for the ego vehicle.
             %       gTruth = state(egoV);
             %
             %       % Obtain INS readings.
             %       sensorReadings = step(sensor, gTruth, s.SimulationTime);
             %       
             %       % Convert readings to geographic coordinates.
             %       [latOut, lonOut] = local2latlon(sensorReadings.Position(1), sensorReadings.Position(2), sensorReadings.Position(3), origin);
             %
             %       % Visualize differences between ground truth locations and locations reported by sensor.
             %       reachedWaypoint = sum(abs(roadCenters(indx,:) - gTruth.Position)) < 1;
             %       if reachedWaypoint
             %           plotPosition(player, latIn(indx), lonIn(indx), 'TrackID', 1, 'Label', 'Ground truth');
             %           plotPosition(player, latOut, lonOut, 'TrackID', 2, 'Label', 'INS position');
             %           indx = indx + 1;
             %       end
             %       if indx > numPoints
             %           break;
             %       end
             %
             %   end
             %
             %   See also smoothTrajectory, insSensor.
             if isa(obj.MotionStrategy,'driving.scenario.Stationary')
                 error(message('driving:scenario:StateRequiresSmoothTrajectory'));
             end
             if ~isa(obj.MotionStrategy,'driving.scenario.SmoothTrajectory')
                 error(message('driving:scenario:StateNotSupported'));
             end
             gTruth = struct( ...
                 'Position', obj.Position, ...
                 'Velocity', obj.Velocity, ...
                 'Orientation', [obj.Roll obj.Pitch obj.Yaw], ...
                 'AngularVelocity', obj.AngularVelocity, ...
                 'Acceleration', obj.Acceleration);
             if nargin > 1
                 % Output additional properties as requested
                 addOnProps = varargin{1};
                 for sndx = 1:length(addOnProps)
                     prop = addOnProps(sndx);
                     if isprop(obj,prop)
                         gTruth.(prop) = obj.(prop);
                     end
                 end
             end
         end
    end
    
    methods (Sealed, Hidden)
        
        function running = move(obj, simulationTime)
            % Determine motion strategies of each actor
            running = false(size(obj));
            path = running;
            stationary = running;
            smoothTraj = running;
            for idx = 1:numel(obj)
               smoothTraj(idx) = isa(obj(idx).MotionStrategy, 'driving.scenario.SmoothTrajectory');
               path(idx) = isa(obj(idx).MotionStrategy, 'driving.scenario.Path') && ~smoothTraj(idx);
               stationary(idx) = ~path(idx) && isa(obj(idx).MotionStrategy, 'driving.scenario.Stationary');
            end
            custom = ~(stationary | path | smoothTraj);
            
            % Call move on array of actors with default motion strategies
            if any(path)
                running(path) = move([obj(path).MotionStrategy], simulationTime);
            end
            if any(smoothTraj)
                running(smoothTraj) = move([obj(smoothTraj).MotionStrategy], simulationTime);
            end
            if any(stationary)
                running(stationary) = move([obj(stationary).MotionStrategy], simulationTime);
            end
            
            % Call move on actors with custom motion strategies
            for idx = find(custom)
                running(idx) = move(obj(idx).MotionStrategy, simulationTime);
            end
        end
        
        function targetList = visibleActors(obj)
            targetList = arrayfun(@(thisActor)eq(thisActor.IsVisible,true),obj);
        end

        function  resetVisibility(obj)
            % reset the actors visibility state
            for idx = 1:numel(obj)
                obj(idx).IsVisible = true;
            end
        end

    end
    
    methods (Hidden)    
        function updatePlots(obj)
            s = obj.Scenario;
            actors = s.Actors;
            for i=1:numel(s.Plots)
                p = s.Plots(i);
                p.plotActors(actors);
                p.plotActorWaypoints(actors);
            end
        end
        
        function posesStruct = egoAndTargetPoses(obj)
            % Get actor list
            actors = obj.Scenario.Actors;            
            egoPos = obj.Position;
            egoVel = obj.Velocity;
            egoAngVel = obj.AngularVelocity;
            R = scenarioToEgoRotator(obj);
            for i=numel(actors):-1:1
                a = actors(i);
                % translate and rotate to ego coordinates
                aPos = (a.Position - egoPos)*R;
                aVel = (a.Velocity - egoVel)*R - cross(deg2rad(egoAngVel),aPos);
                aAngVel = a.AngularVelocity - egoAngVel;
                [aRoll, aPitch, aYaw] = scenarioToEgoOrientation(obj,a);

                % store into target structure array
                posesStruct(i) = struct('ActorID',a.ActorID, ...
                                        'ClassID',a.ClassID, ...
                                        'Position',aPos, ...
                                        'Velocity',aVel, ...
                                        'Roll',aRoll, ...
                                        'Pitch',aPitch, ...
                                        'Yaw',aYaw, ...
                                        'AngularVelocity',aAngVel);
            end
            % Repeat for barrier segments
            offset = numel(actors);
            if isa(obj.Scenario.Barriers, 'driving.scenario.Barrier') && ...
               ~isempty(obj.Scenario.Barriers)
                barrierSegments = [obj.Scenario.Barriers(:).BarrierSegments];
                for i=numel(barrierSegments):-1:1
                    a = barrierSegments(i);

                    % translate and rotate to ego coordinates
                    aPos = (a.Position - egoPos)*R;
                    aVel = (a.Velocity - egoVel)*R - cross(deg2rad(egoAngVel),aPos);
                    aAngVel = a.AngularVelocity - egoAngVel;
                    [aRoll, aPitch, aYaw] = scenarioToEgoOrientation(obj,a);

                    % store into target structure array
                    posesStruct(i + offset) = struct('ActorID',a.getEncodedActorID(), ...
                                            'ClassID',a.ClassID, ...
                                            'Position',aPos, ...
                                            'Velocity',aVel, ...
                                            'Roll',aRoll, ...
                                            'Pitch',aPitch, ...
                                            'Yaw',aYaw, ...
                                            'AngularVelocity',aAngVel);
                end
            end
        end

        function validateEgoActor(egoActor)
            if ~(egoActor.EntryTime == 0 && egoActor.ExitTime == Inf)
                error(message('driving:scenario:EgoVehicleRemoved'));
            end
        end

         function validateActorEntryTime(obj, enttime)
            validateattributes(enttime,{'numeric'},{'real','vector','nonnegative','finite',},'actor','EntryTime');
            if any(enttime(2:end)-enttime(1:end-1)<0)                
                error(message('driving:scenario:EntryTimeMismatch'));
            end
            if size(obj.ExitTime,2)== size(enttime,2)
                if any(enttime >= obj.ExitTime) || any(isempty(enttime))
                    error(message('driving:scenario:InvalidEntryTime'));
                end
                obj.IsSpawnValid = true;
            else
                obj.IsSpawnValid = false;
            end

        end

        function validateActorExitTime(obj, exttime)
            validateattributes(exttime,{'numeric'},{'real','vector'},'actor','ExitTime');
            if any(exttime(2:end)-exttime(1:end-1)<0)
                error(message('driving:scenario:ExitTimeMismatch'));
            end
            if size(obj.EntryTime,2)== size(exttime,2)
                if any(obj.EntryTime >= exttime) || any(isnan(exttime))
                    error(message('driving:scenario:InvalidExitTime'));
                end
                obj.IsSpawnValid = true;
            else
                obj.IsSpawnValid = false;
            end
        end

        function isActorSpawnValid(obj)
            if any(obj.EntryTime(1) >= obj.Scenario.StopTime)
                warning(message('driving:scenario:EntryTimeExceedsStopTime'));
            end
            if ~isinf(obj.ExitTime(1)) && any(obj.ExitTime(1) > obj.Scenario.StopTime)
                warning(message('driving:scenario:ExitTimeExceedsStopTime'));
            end
        end

        function updateTrajectory(obj)
            if ~isempty(obj.MotionStrategy) && isprop(obj.MotionStrategy, 'Waypoints')
                waypoints = obj.MotionStrategy.Waypoints;
                speed = obj.MotionStrategy.Speed;
                waittime = obj.MotionStrategy.WaitTime;
                % Yaw is stored as radians but input as degrees
                yaw = rad2deg(obj.MotionStrategy.Yaw);
                otherArgs = {};
                if ~isempty(waittime)
                    otherArgs = horzcat(otherArgs,{waittime});
                end
                if ~isempty(yaw)
                    otherArgs = horzcat(otherArgs, {'Yaw',yaw});
                end
                if isa(obj.MotionStrategy,'driving.scenario.SmoothTrajectory')
                    trajectoryFnc = @smoothTrajectory;
                    otherArgs = horzcat(otherArgs,{'Jerk',obj.MotionStrategy.Jerk});
                else
                    trajectoryFnc = @trajectory;
                end
                trajectoryFnc(obj, waypoints, speed, otherArgs{:});
            end
        end

    end
    
    methods (Hidden, Static)
        function color = getDefaultColorForActorID(id)
            colors = get(groot, 'DefaultAxesColorOrder');
            color  = colors(rem(id - 1, size(colors, 1)) + 1, :);
        end
    end
end

classdef GamingEngineAssetFactory < handle
% 虚幻引擎资产工厂

    properties (SetAccess=protected, Hidden)
        CameraInputs
    end
    
    methods (Static)
        function [actor, warnid] = createActorAsset(actorType, actorInfo, isEgo)
            
            warnid = {};
            % 检查尺寸，如果偏差超过1毫米，则发出警告
            dims = driving.scenario.internal.GamingEngineScenarioAnimator.getAssetDimensions(actorType);
            props = fieldnames(dims);
            for indx = 1:numel(props)
                if abs(actorInfo.(props{indx}) - dims.(props{indx})) > 0.001
                    warnid = [warnid {['driving:scenarioApp:GamingEngineDimsWarning' props{indx}]}];
                end
            end
            switch actorType
                % 参与者类型：捷达、运动型多用途车（越野车）、肌肉车、掀背车、小型皮卡、箱式卡车
                case {'Sedan','MuscleCar','SportUtilityVehicle', 'Hatchback', 'SmallPickupTruck','BoxTruck'}
                    actor.Type = actorType;
                    if isEgo
                        actor.Tag = 'SimulinkVehicle1';
                    else
                        actor.Tag = sprintf('vehicle%d', actorInfo.ActorID);
                    end
                    actor.Translation = zeros(5, 3, 'single');
                    actor.Translation(1,:) = single(actorInfo.TPosition);
                    actor.Rotation = zeros(5, 3, 'single');
                    actor.Rotation(1,3) = -single(actorInfo.TYaw); % need to negate?
                    actor.Scale = ones(5, 3, 'single');
                    [color, shouldWarn] = driving.scenario.internal.GamingEngineAssetFactory.rgbToUnrealActorString(actorInfo.PlotColor);
                    if shouldWarn
                        warnid = [warnid {'driving:scenarioApp:GamingEngineColorWarning'}];
                    end
                    actor.Obj = sim3d.auto.PassengerVehicle(actor.Tag,actorType,...
                        'Color', color, ...
                        'Translation',actor.Translation(1,:),...
                        'Scale', single([1 1 1]), ...
                        'Rotation',actor.Rotation(1,:), ...
                        'ActorID', actorInfo.ActorID);
                    actor.Obj.setup();
                    actor.Obj.reset();
                case {'MalePedestrian', 'FemalePedestrian'}
                    actor.Type = actorType;
                    actor.Tag = sprintf('pedestrian%d', actorInfo.ActorID);
                    actor.Translation = single(actorInfo.TPosition);
                    actor.Rotation = zeros(1, 3, 'single');
                    actor.Rotation(1,3) = single(pi / 2 - actorInfo.TYaw);
                    actor.Scale = ones(1, 3, 'single');
                    I = matlabshared.application.IgnoreWarnings('sim3d:pedestrians:Pedestrian:DeprecatedPedestrianType');
                    I.RethrowWarning = false;
                    if strcmp(actorType, 'MalePedestrian')
                        type = 'human_01';
                    else
                        type = 'human_06';
                    end
                    actor.Obj = sim3d.pedestrians.Pedestrian(actor.Tag, type,...
                        'Translation',actor.Translation,...
                        'Rotation',actor.Rotation(1:3));
                    actor.Obj.setup();
                    actor.Obj.reset();
                case 'Bicyclist'
                    try
                        actor.Type = actorType;
                        actor.Tag = sprintf('pedestrian%d', actorInfo.ActorID);
                        actor.Translation = single(actorInfo.TPosition);
                        actor.Rotation = zeros(1, 3, 'single');
                        actor.Rotation(1,3) = single(pi / 2 - actorInfo.TYaw);
                        actor.Scale = ones(1, 3, 'single');
                        actor.Obj = sim3d.pedestrians.Bicyclist(actor.Tag, ...
                            'Translation',actor.Translation,...
                            'Rotation',actor.Rotation(1:3));
                        actor.Obj.setup();
                        actor.Obj.reset();
                    catch ME %#ok<NASGU>
                        actor = driving.scenario.internal.GamingEngineAssetFactory.createActorAsset('MalePedestrian', actorInfo, isEgo);
                        if strcmp(actorType, 'Bicyclist')
                            warnid = {'driving:scenarioApp:GamingEngineNoBicycleWarning'};
                        end
                    end
                case 'Barrier'
                    obj = sim3d.utils.CreateActor;
                    obj.setCreateActorType(sim3d.utils.ActorTypes.BaseStatic);
                    location.translation = actorInfo.TPosition;
                    location.rotation    = [0 0 pi / 2 - actorInfo.TYaw];
                    location.scale       = [actorInfo.Width actorInfo.Length/2.5 actorInfo.Height];
                    obj.setActorLocation(location);
                    obj.setParentName('Scene Origin');
                    obj.setActorName(sprintf('Barrier%d', actorInfo.ActorID));
                    obj.setMesh('/Game/Environment/Industrial/Props/Barriers/Mesh/SM_Barrier.SM_Barrier');
                    obj.setMobility(int32(sim3d.utils.MobilityTypes.Movable));
                    obj.write % not sure why this write is necessary its called later
                    actor.Obj = obj;
                    
                case 'Cuboid'
                    actor.Type = actorType;
                    if isEgo
                        error(message('driving:scenarioApp:GamingEngineEgoIsCuboid'));
                    else
                        actor.Tag = sprintf('Cuboid%d', actorInfo.ActorID);
                    end
                    actor.Translation = zeros(1, 3, 'single');
                    actor.Translation(1,:) = single(actorInfo.TPosition);
                    actor.Rotation = zeros(1, 3, 'single');
                    actor.Rotation(1,3) = pi - single(actorInfo.TYaw); % need to negate?
                    actor.Scale = single([actorInfo.Length actorInfo.Width actorInfo.Height * 1.9]);
                    actor.Tag = sprintf('Cuboid%d', actorInfo.ActorID);
                    actor.Obj = driving.scenario.internal.GamingEngineUnknown(actor.Tag, ...
                        'Translation', actor.Translation, ...
                        'Rotation', actor.Rotation, ...
                        'Scale', actor.Scale, ...
                        'ActorID', actorInfo.ActorID);
                    if isfield(actorInfo, 'Waypoints') && size(actorInfo.Waypoints, 1) > 1
                        warnid = [warnid {'driving:scenarioApp:GamingEngineCuboidMotionWarning'}];
                    end
                otherwise
                    assert(false,"Unknown actor type");
            end
        end
        
        function [road, warnings] = createRoadAsset(~, roadInfo)
            [roadCenters, roadWidths, angles, styles, colors, widths, warnings] = getRoadInformation(roadInfo);
            % 在游戏中创建道路
            % 添加
            RoadTranslation = single([0,0,0.1]);
            roadName = ['Road' num2str(roadInfo.Index)];
            try
                road = sim3d.road.Road(roadName, roadCenters, angles,...
                    roadWidths, styles, colors, widths, 'Translation', RoadTranslation);
                road.setup();
            catch ME
                try
                    widths = repmat(lanespec.DefaultWidth, 1, numel(styles) - 1);
                    % Special case [s d u s] to be [s d u] & others
                    % ??? LKA missing styles. What to do?
                    % - LKA s s d s not available. (mesh 7 maybe best alt?)
                    % - LKA s d u d also not available (mesh 4 best alt?)
                    % - LKA s s u s (mesh 8 flipped?)  & s u s s (mesh 8  maybe?) - not avail
                    if isequal(styles,["Solid","Dashed","Unmarked","Solid"])
                        styles = ["Solid","Dashed","Unmarked"];
                        colors = ["w","w"," "];
                        widths = [lanespec.DefaultWidth lanespec.DefaultWidth];
                    elseif isequal(styles,["Solid","Unmarked","Unmarked"])
                        styles = "Unmarked";
                        colors = " ";
                        widths = [];
                    elseif isequal(styles, ["Unmarked", "Solid","Dashed","DoubleSolid","Dashed","Solid","Unmarked"])
                        colors = [" ","w","w","y","w","w"," "];
                        widths = [0.5 ones(1,4).*lanespec.DefaultWidth 0.5];
                    elseif numel(styles) < 6
                        styles = ["Unmarked",styles,"Unmarked"]; %#ok<*AGROW> % append and prepend "Unmarked" to correct mesh type
                        colors = [" ",colors," "];
                        % TODO - exact postion of lanes, length, width. strength etc
                        widths = [0.5,widths,0.5];
                    end
                    road = sim3d.road.Road(roadName, roadCenters, angles,...
                        roadWidths, styles, colors, widths, 'Translation', RoadTranslation);
                    road.setup();
                catch ME
                    try
                        road = sim3d.road.Road(roadName, roadCenters, angles, ...
                            roadWidths, "Unmarked", " ", [], 'Translation', RoadTranslation);
                        road.setup();
                    catch ME
                        rethrow(ME);
                    end
                end
                % cant use ids for road issues because the sim3d apsi
                % hardcodes the strings.
                warnings = [warnings {ME.message}];
            end
        end
        
        function [str, shouldWarn] = rgbToUnrealActorString(rgb, validColors)
            
            defaults = lines(7);
            dist = sum((defaults - rgb).^2, 2);
            i = find(dist == 0, 1, 'first');
            % Special case the default colors.
            if ~isempty(i)
                strs = {'blue', 'orange', 'yellow', 'black', 'green', 'bluesilver', 'red', 'blue'};
                str = strs{i};
                shouldWarn = false;
                return;
            end
            
            colors.black = [48 48 48] / 255;
            colors.red = [160 33 33] / 255;
            colors.orange = [253 127 55] / 255;
            colors.yellow = [223 169 0] / 255;
            colors.green = [51 124 50] / 255;
            colors.blue = [15 47 89] / 255;
            colors.white = [224 222 217] / 255;
            colors.whitepearl = [232 231 225] / 255;
            colors.grey = [140 145 139] / 255;
            colors.darkgrey = [63 63 63] / 255;
            colors.silver = [218 230 226] / 255;
            colors.bluesilver = [224 249 255] / 255;
            colors.darkredblack = [101 89 82] / 255;
            colors.redblack = [80 43 38] / 255;

            if nargin > 1
                validColorStruct = struct;
                for indx = 1:numel(validColors)
                    validColorStruct.(validColors{indx}) = colors.(lower(validColors{indx}));
                end
                colors = validColorStruct;
            end
            
            values = struct2cell(colors);
            values = vertcat(values{:});
            
            names = fieldnames(colors);
            
            % dist = sum((rgb2hsv(values) - rgb2hsv(rgb)).^2, 2) + sum((values - rgb).^2 .* [.9 1.77 .33], 2);
            % dist = sum((values - rgb).^2 .* [.9 1.77 .33], 2);
            % dist = sum((rgb2hsv(values) - rgb2hsv(rgb)).^2, 2) + sum((values - rgb).^2, 2);
            dist = sum((values - rgb).^2, 2);
            
            [~, i] = min(dist);
            str = names{i(1)};
            shouldWarn = dist(i) > 0.2;
            
        end
        
    end
    
    methods (Static = false)
        function camera = createCamera(this, varargin)
            this.CameraInputs = varargin;
            camera = sim3d.sensors.MainCamera(varargin{:});
            camera.setup();
            camera.reset();
        end
    end
    
end

function [roadCenters, roadWidths, angles, styles, colors, widths, warnings] = getRoadInformation(road)

warnings = {};
roadCenters = road.Centers;
x = roadCenters(:,1);
y = roadCenters(:,2);
z = roadCenters(:,3);

if isempty(road.Lanes)
    road.Lanes = lanespec(1, 'Width', road.Width);
elseif isa(road.Lanes, 'compositeLaneSpec')
    warnings = [warnings {getString(message('driving:scenarioApp:GamingEngineCompositeLaneWarning'))}];
    road.Lanes = lanespec(1, 'Width', mean(road.Width));
end

[rcX, rcY, rcZ, angles] = driving.scenario.internal.clothoidSubSample(x, y, 9, z, road);

% angles = deg2rad(angles);
angles = angles(:);
numCenters = numel(rcX);
roadCenters = [rcX rcY rcZ];
roadWidths = ones(numCenters,1,'single');

badColors = [];
shouldCompositeWarn = false;
shouldCompositeLaneSpecWarn = false;

if isempty(road.Lanes)
    styles = ["Unmarked" "Unmarked"];
    colors = [" " " "];
    widths = road.Width;
else
    laneSpec = road.Lanes;
    if isa(laneSpec,'compositeLaneSpec')
        laneSpec = laneSpec.LaneSpecification(1);
        shouldCompositeLaneSpecWarn = true;
    end
    markings = laneSpec.Marking;
    colors = repmat(" ", 1, numel(markings));
    styles = colors;
    badColors = [];    
    for indx = 1:numel(markings)
        if isa(markings(indx), 'driving.scenario.CompositeMarking')
            markings(indx) = markings(indx).Markings(1);
            shouldCompositeWarn = true;
        end
        styles(indx) = markings(indx).Type;
        if isprop(markings(indx), 'Color')
            [colors(indx), shouldColorWarn] = rgbToUnrealLaneString(markings(indx).Color);
            if shouldColorWarn
                badColors = [badColors indx];
            end
        end
    end    
    if any(strcmp(styles(1), {'Dashed', 'DashedSolid', 'DoubleDashed'})) || any(strcmp(styles(end), {'Dashed', 'SolidDashed', 'DoubleDashed'}))
        warnings = [warnings {getString(message('driving:scenarioApp:GamingEngineLanePositionWarning'))}];
    end
    
    widths = laneSpec.Width;
end
if ~isempty(badColors)
    indices = matlabshared.application.IndexedWarnings.convertIdsToString(badColors);
    warnings = [warnings {getString(message('driving:scenarioApp:GamingEngineLaneColorWarning', indices))}];
end
if shouldCompositeWarn
    warnings = [warnings {getString(message('driving:scenarioApp:GamingEngineMMSWarning'))}];
end

if shouldCompositeLaneSpecWarn
    warnings = [warnings {getString(message('driving:scenarioApp:GamingEngineMLSWarning'))}];
end
end

function [str, shouldWarn] = rgbToUnrealLaneString(rgb)


colors.w  = [231 231 231] / 255;
colors.y  = [247 209  23] / 255;
colors.o  = [229 114   0] / 255;
colors.r  = [166  25  46] / 255;
colors.b  = [  0  56 130] / 255;
colors.br = [105  63  35] / 255;
colors.g  = [  0 103  71] / 255;
colors.p  = [219  77 105] / 255;
colors.pr = [109  32 119] / 255;
colors.yg = [196 214   0] / 255;

values = struct2cell(colors);
values = vertcat(values{:});

names = fieldnames(colors);

dist = sum((rgb2hsv(values) - rgb2hsv(rgb)).^2, 2);

[~, i] = min(dist);
if dist(i) > 0.1
    shouldWarn = true;
    str = 'w';
else
    shouldWarn = false;
    str = names{i(1)};
end

end



% [EOF]

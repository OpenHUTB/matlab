classdef Road < handle
    %ROAD 表示驾驶场景中一条路的对象。
    %   A Road object is returned as output by the road method in the
    %   drivingScenario class.
    %
    %   See also drivingScenario/road.
    
    
    properties (SetAccess = protected)
        % 名称
        %     道路名称
        Name = ""
        % RoadID
        %     道路ID
        RoadID         
        % RoadCenters
        %     道路中心点
        RoadCenters
        % RoadWidth
        %     道路的总宽度
        RoadWidth
        % BankAngle
        %     道路的倾斜角
        BankAngle 
        % Heading
        %     道路的偏航角
        Heading    
    end
    
    methods
        function obj = Road(roadSegment)
            % 获取类属性
            prop = properties(obj);
            % 在 driving.scenario.RoadSegment 中名称不是属性
            prop(contains(prop, 'Name')) = [];
            
            % Populate class properties from RoadSegment
            for i = 1:numel(prop)
                thisProp = prop{i};
                obj.(thisProp) = roadSegment.(thisProp);
            end
            
            % Get name if not empty
            if ~strcmp(roadSegment.RoadName, "")
                obj.Name = roadSegment.RoadName;
            end
        end
    end
end


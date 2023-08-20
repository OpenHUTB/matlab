classdef TextureTransform

    properties

        Position(1,2)double=[0,0];
        Velocity(1,2)double=[0,0];
        Scale(1,2)double=[1,1];
        Angle(1,1)double=0;
    end


    methods

        function obj=TextureTransform(varargin)
            for i=1:nargin/2
                obj.(varargin{i*2-1})=varargin{i*2};
            end
        end
    end


    methods(Hidden)

        function Data=getData(obj)
            Data=[obj.Position,obj.Velocity,obj.Scale,obj.Angle];
        end
    end

end
classdef TextureMapping


    properties

        Blend(1,3)double=[0,0,0];

        Displacement(1,3)double=[0,0,0];

        Bumps(1,3)double=[0,0,0];

        Roughness(1,3)double=[0,0,0];
    end

    methods
        function obj=TextureMapping(varargin)
            for i=1:nargin/2
                obj.(varargin{i*2-1})=varargin{i*2};
            end
        end
    end

    methods(Hidden)
        function Data=getData(obj)
            Data=[obj.Blend,obj.Displacement,obj.Bumps,obj.Roughness];
        end
    end

end
classdef WaveformName<handle&matlab.mixin.Heterogeneous&...
    matlab.mixin.CustomDisplay



    properties
Name
    end
    properties(Abstract,Constant,Access=protected)
DefaultName
    end
    methods
        function self=WaveformName(varargin)
            narginchk(0,1)
            self.Name=self.DefaultName;
        end
    end

    methods
        function set.Name(self,newName)
            self.Name=newName;
        end
    end
end
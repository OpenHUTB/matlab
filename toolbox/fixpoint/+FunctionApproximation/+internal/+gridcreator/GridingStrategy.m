classdef(Abstract)GridingStrategy





    properties(SetAccess=protected)
        DataTypes;
    end

    methods
        function this=GridingStrategy(dataTypes)


            this.DataTypes=dataTypes;
        end


        function grid=getGrid(this,rangeObject,varargin)



            grid=execute(this,rangeObject,varargin{:});
        end
    end

    methods(Access=protected)
        grid=execute(this,rangeObject,varargin);
    end
end



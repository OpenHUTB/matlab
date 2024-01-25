classdef AxesLayout<icomm.pi.app.Container
    properties(Abstract,GetAccess=public,SetAccess=public,Dependent)
NumAxes
    end

    properties(GetAccess=protected,SetAccess=protected)
        Axes matlab.graphics.axis.Axes
    end


    methods(Access=public)

        function this=AxesLayout(varargin)
            this@icomm.pi.app.Container(varargin{:});
        end

    end


    methods(Abstract,Access=public)
        thisAxes=getAxes(this,rowIndex,columnIndex)

    end

end
classdef rcRx<serdes.internal.serdesquicksimulation.SERDESElement

    methods
        function obj=rcRx(varargin)
            obj@serdes.internal.serdesquicksimulation.SERDESElement(varargin{:});
        end


        function value=get.R(obj)
            value=obj.R;
        end


        function set.R(obj,value)
            validateattributes(value,{'numeric'},{'nonempty','scalar','finite','nonnan','nonnegative','nonzero','<=',100e6},'',obj.R_NameInGUI);
            obj.R=value;
        end


        function value=get.C(obj)
            value=obj.C;
        end


        function set.C(obj,value)
            validateattributes(value,{'numeric'},{'nonempty','scalar','finite','nonnan','nonnegative'},'',obj.C_NameInGUI);
            obj.C=value;
        end
    end


    properties
        R=50;
        C=2e-13;
    end


    properties(Constant,Hidden)
        R_NameInGUI=getString(message('serdes:serdesdesigner:R_NameInGUI'));
        C_NameInGUI=getString(message('serdes:serdesdesigner:C_NameInGUI'));
        R_ToolTip=getString(message('serdes:serdesdesigner:AnalogR'));
        C_ToolTip=getString(message('serdes:serdesdesigner:AnalogC'));
    end


    properties(Constant,Access=protected)
        HeaderDescription=getString(message('serdes:serdesdesigner:AnalogInHdrDesc'));
    end


    properties(Constant,Hidden)
        DefaultName='AnalogIn';
    end


    methods(Hidden,Access=protected)
        function out=localClone(in)
            out=serdes.internal.apps.serdesdesigner.rcRx;
            copyProperties(in,out);
        end
    end
end

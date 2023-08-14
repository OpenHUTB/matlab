classdef rcTx<serdes.internal.serdesquicksimulation.SERDESElement




    methods
        function obj=rcTx(varargin)
            obj@serdes.internal.serdesquicksimulation.SERDESElement(varargin{:});
        end

        function value=get.Voltage(obj)
            value=obj.Voltage;
        end
        function set.Voltage(obj,value)
            validateattributes(value,{'numeric'},{'nonempty','scalar','finite','nonnan','nonnegative','nonzero'},'',obj.Voltage_NameInGUI);
            obj.Voltage=value;
        end

        function value=get.RiseTime(obj)
            value=obj.RiseTime;
        end
        function set.RiseTime(obj,value)
            validateattributes(value,{'numeric'},{'nonempty','scalar','finite','nonnan','nonnegative','nonzero'},'',obj.RiseTime_NameInGUI);
            obj.RiseTime=value;
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
        Voltage=1;
        RiseTime=10e-12;
        R=50;
        C=1e-13;
    end

    properties(Constant,Hidden)
        Voltage_NameInGUI=getString(message('serdes:serdesdesigner:Voltage_NameInGUI'));
        RiseTime_NameInGUI=getString(message('serdes:serdesdesigner:RiseTime_NameInGUI'));
        R_NameInGUI=getString(message('serdes:serdesdesigner:R_NameInGUI'));
        C_NameInGUI=getString(message('serdes:serdesdesigner:C_NameInGUI'));

        Voltage_ToolTip=getString(message('serdes:serdesdesigner:AnalogVolts'));
        RiseTime_ToolTip=getString(message('serdes:serdesdesigner:AnalogRiseTime'));
        R_ToolTip=getString(message('serdes:serdesdesigner:AnalogR'));
        C_ToolTip=getString(message('serdes:serdesdesigner:AnalogC'));
    end

    properties(Constant,Access=protected)
        HeaderDescription=getString(message('serdes:serdesdesigner:AnalogOutHdrDesc'));
    end
    properties(Constant,Hidden)
        DefaultName='AnalogOut';
    end

    methods(Hidden,Access=protected)
        function out=localClone(in)
            out=serdes.internal.apps.serdesdesigner.rcTx;
            copyProperties(in,out);
        end
    end
end

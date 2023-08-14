classdef Integrator<matlab.system.CoreBlockSystem

































%#codegen
%#ok<*EMCLS>
%#ok<*EMCA>

    properties






        CustomAccumulatorDataType=numerictype(true,16,0);
    end

    methods

        function obj=Integrator(varargin)
            obj@matlab.system.CoreBlockSystem('DSPIntegrator');
            setProperties(obj,nargin,varargin{:});
        end
        function set.CustomAccumulatorDataType(obj,val)
            validateCustomDataType(obj,'CustomAccumulatorDataType',val,{'SIGNED','SCALED'});
            obj.CustomAccumulatorDataType=val;
        end
    end

    methods(Hidden)
        function props=createCustomDataTypeStr(~,numericObj)
            props.DataTypeMode='Fixed-point: binary point scaling';
            if numericObj.Signed
                props.Signedness='Signed';
            else
                props.Signedness='Unsigned';
            end
            props.WordLength=int32(numericObj.WordLength);
            props.FractionLength=int32(numericObj.FractionLength);
            props.Slope=0;
            props.Bias=0;
            props.IsAlias=false;
        end

        function setParameters(obj)
            AccumDataTypeStr=createCustomDataTypeStr(obj,obj.CustomAccumulatorDataType);
            obj.compSetParameters({AccumDataTypeStr});
        end
    end

    methods(Static,Hidden)
        function desc=getDescription
            desc='DSP Integrator';
        end
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end

    methods(Access=protected)
        function setPortDataTypeConnections(this)
            setPortDataTypeConnection(this,1,1);
        end
    end

end

classdef OSTBCEncoder<matlab.system.SFunSystem











































































































%#function mcomostbcenc



%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)



        NumTransmitAntennas=2;





        SymbolRate=3/4;








        OverflowAction='Wrap';
    end

    properties(Constant,Hidden)
        OverflowActionSet=dsp.CommonSets.getSet('OverflowAction');
    end

    methods

        function obj=OSTBCEncoder(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mcomostbcenc');
            setProperties(obj,nargin,varargin{:},'NumTransmitAntennas');
            setVarSizeAllowedStatus(obj,true);
            setForceInputRealToComplex(obj,1,true);
        end


        function set.NumTransmitAntennas(obj,value)
            validateattributes(value,{'numeric'},{'>=',2,'<=',4,'scalar','integer'},'','NumTransmitAntennas');
            obj.NumTransmitAntennas=value;
        end

        function set.SymbolRate(obj,value)
            validateattributes(value,{'numeric'},{'scalar'},'','SymbolRate');
            if value~=3/4&&value~=1/2
                coder.internal.errorIf(true,'comm:system:OSTBCEncoder:invalidSymbolRate');
            else
                obj.SymbolRate=value;
            end
        end
    end

    methods(Hidden)
        function setParameters(obj)



            NumTransmitAntennasIdx=obj.NumTransmitAntennas-1;
            switch(obj.SymbolRate)
            case 3/4
                SymbolRateIdx=1;
            case 1/2
                SymbolRateIdx=2;
            end
            OverflowActionIdx=getIndex(...
            obj.OverflowActionSet,obj.OverflowAction);


            obj.compSetParameters({...
            NumTransmitAntennasIdx,...
            SymbolRateIdx,...
            1,...
OverflowActionIdx...
            });
        end
        function y=supportsUnboundedIO(~)
            y=true;
        end
    end

    methods(Access=protected)
        function flag=isInactivePropertyImpl(obj,prop)
            props={};
            if obj.NumTransmitAntennas==2
                props={'SymbolRate'};
            end
            flag=ismember(prop,props);
        end

        function setPortDataTypeConnections(obj)
            setPortDataTypeConnection(obj,1,1);
        end
    end

    methods(Static)
        function helpFixedPoint






            matlab.system.dispFixptHelp('comm.OSTBCEncoder',...
            comm.OSTBCEncoder.getDisplayFixedPointPropertiesImpl);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='commmimo/OSTBC Encoder';
        end

        function props=getDisplayPropertiesImpl
            props={...
            'NumTransmitAntennas',...
            'SymbolRate'};
        end

        function props=getDisplayFixedPointPropertiesImpl
            props={...
            'OverflowAction'};
        end


        function props=getValueOnlyProperties()
            props={'NumTransmitAntennas'};
        end
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end
end


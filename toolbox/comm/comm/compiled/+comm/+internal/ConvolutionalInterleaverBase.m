classdef ConvolutionalInterleaverBase<matlab.system.SFunSystem







%#function mcomgenmuxint

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)



        NumRegisters=6;
    end

    properties(Abstract,Access=protected,Nontunable)

pIsInterleaver
    end

    methods

        function obj=ConvolutionalInterleaverBase(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mcomgenmuxint');
            setProperties(obj,nargin,varargin{:});
            setVarSizeAllowedStatus(obj,false);
        end

        function set.NumRegisters(obj,value)
            validateattributes(value,{'numeric'},...
            {'finite','nonempty','positive','integer','scalar'},'','NumRegisters');
            obj.NumRegisters=value;
        end
    end

    methods(Hidden)
        function setParameters(obj)

            [m,n]=size(obj.InitialConditions);
            coder.internal.errorIf(((m>1)&&(m~=obj.NumRegisters))||(n~=1),'comm:system:ConvolutionalInterleaver:InitialConditions');


            delay=(0:obj.RegisterLengthStep:...
            obj.RegisterLengthStep*(obj.NumRegisters-1))';
            if~obj.pIsInterleaver
                delay=max(delay)-delay;
            end

            obj.compSetParameters({...
            delay,...
            obj.InitialConditions...
            });
        end
    end

    methods(Static,Hidden)
        function props=getDisplayPropertiesImpl()
            props={
            'NumRegisters',...
            'RegisterLengthStep',...
            'InitialConditions'};
        end
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end
end


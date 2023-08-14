classdef ScalarQuantizerDecoder<matlab.system.SFunSystem



























































%#function mdspsqdec

%#ok<*EMCLS>
%#ok<*EMCA>

    properties





        Codebook=1:10;
    end

    properties(Nontunable)



        CodebookSource='Property';





        OutputDataType='double';







        CustomOutputDataType=numerictype(true,16);
    end

    properties(Constant,Hidden)
        CodebookSourceSet=dsp.CommonSets.getSet('PropertyOrInputPort');
        OutputDataTypeSet=matlab.system.StringSet({...
        'Same as input','double','single',...
        matlab.system.getSpecifyString('either')});
    end

    methods
        function obj=ScalarQuantizerDecoder(varargin)
            coder.allowpcode('plain');
            coder.internal.warning('dsp:system:ScalarQuantizerDecoder_NotSupported');
            obj@matlab.system.SFunSystem('mdspsqdec');
            setProperties(obj,nargin,varargin{:});
            setVarSizeAllowedStatus(obj,false);
        end

        function set.CustomOutputDataType(obj,val)
            validateCustomDataType(obj,'CustomOutputDataType',val,...
            {'SPECSIGNED','ALLOWFLOAT'});
            obj.CustomOutputDataType=val;
        end

    end

    methods(Hidden)
        function setParameters(obj)
            CBsource=getIndex(...
            obj.CodebookSourceSet,obj.CodebookSource);
            Invalidin=1;

            if strcmpi(obj.CodebookSource,'Property')
                CodebookIdx=obj.Codebook;
            else
                CodebookIdx=1:10;
            end

            if strcmpi(obj.OutputDataType,'Same as input')


                dtInfo.IsScaled=false;
                dtInfo.IsSigned=false;
                dtInfo.WordLength=2;
                dtInfo.FractionLength=0;
                dtInfo.Id=-3;
            else
                dtInfo=getSourceDataTypeInfo(obj,max(abs(CodebookIdx)));
            end

            obj.compSetParameters({...
            CBsource,...
            CodebookIdx,...
            Invalidin,...
            0,...
            double(dtInfo.IsSigned),...
            dtInfo.Id,...
            dtInfo.WordLength,...
            dtInfo.FractionLength
            });
        end
    end

    methods(Access=protected)


        function flag=isInactivePropertyImpl(obj,prop)
            flag=false;
            switch prop
            case 'CustomOutputDataType'
                if strcmp(obj.CodebookSource,'Input port')||...
                    ~matlab.system.isSpecifiedTypeMode(obj.OutputDataType)
                    flag=true;
                end
            case{'Codebook','OutputDataType'}
                if strcmp(obj.CodebookSource,'Input port')
                    flag=true;
                end
            end
        end
    end

    methods(Static)
        function helpFixedPoint






            matlab.system.dispFixptHelp('dsp.ScalarQuantizerDecoder',dsp.ScalarQuantizerDecoder.getDisplayFixedPointPropertiesImpl);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='dspquant2/Scalar Quantizer Decoder';
        end

        function props=getDisplayPropertiesImpl()
            props={...
            'CodebookSource',...
            'Codebook',...
'OutputDataType'
            };
        end

        function props=getDisplayFixedPointPropertiesImpl()
            props={'CustomOutputDataType'};
        end



        function tunePropsMap=getTunablePropertiesMap()
            tunePropsMap.Codebook=1;
        end
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end
    methods(Access=protected)
        function setPortDataTypeConnections(obj)

            if strcmp(obj.CodebookSource,'Input port')
                setPortDataTypeConnection(obj,2,1);
            end

        end
    end
end

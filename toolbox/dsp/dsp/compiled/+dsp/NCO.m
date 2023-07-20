classdef NCO<matlab.system.SFunSystem






















































































































%#function mdspnco

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)



        PhaseIncrementSource='Input port';




        PhaseIncrement=100;



        PhaseOffsetSource='Property';




        PhaseOffset=0;




        NumDitherBits=4;







        NumQuantizerAccumulatorBits=12;




        Waveform='Sine';











        SamplesPerFrame=1;





        RoundingMethod='Floor';


        OverflowAction='Wrap';


        AccumulatorDataType='Custom';






        CustomAccumulatorDataType=numerictype([],16);



        OutputDataType='Custom';







        CustomOutputDataType=numerictype([],16,14);






        Dither(1,1)logical=true;



        PhaseQuantization(1,1)logical=true;





        PhaseQuantizationErrorOutputPort(1,1)logical=false;
    end

    properties(Constant,Hidden)
        PhaseIncrementSourceSet=dsp.CommonSets.getSet('PropertyOrInputPort');
        PhaseOffsetSourceSet=dsp.CommonSets.getSet('PropertyOrInputPort');
        WaveformSet=matlab.system.StringSet({...
        'Sine',...
        'Cosine',...
        'Complex exponential',...
        'Sine and cosine'});
        RoundingMethodSet=matlab.system.StringSet({'Floor'});
        OverflowActionSet=matlab.system.StringSet({'Wrap'});
        AccumulatorDataTypeSet=dsp.CommonSets.getSet('FixptModeUnscaledOnly');
        OutputDataTypeSet=matlab.system.StringSet({...
        'double','single',matlab.system.getSpecifyString('scaled')});
    end

    properties(Constant,Hidden,Nontunable)




        PNGeneratorLength=19;
    end

    methods
        function obj=NCO(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mdspnco');
            setProperties(obj,nargin,varargin{:});
            setVarSizeAllowedStatus(obj,false);
        end

        function set.CustomAccumulatorDataType(obj,val)
            validateCustomDataType(obj,'CustomAccumulatorDataType',val,...
            {'AUTOSIGNED','NOTSCALED'});
            obj.CustomAccumulatorDataType=val;
        end
        function set.CustomOutputDataType(obj,val)
            validateCustomDataType(obj,'CustomOutputDataType',val,...
            {'AUTOSIGNED','SCALED','ALLOWFLOAT'});
            obj.CustomOutputDataType=val;
        end

    end

    methods(Access=protected)
        function s=infoImpl(obj)
















            if obj.PhaseQuantization
                s.NumPointsLUT=2^(obj.NumQuantizerAccumulatorBits-2)+1;
                s.SineLUTSize=...
                round(s.NumPointsLUT*getOutputWordLength(obj,obj.OutputDataType)/8);
                if obj.Dither
                    s.TheoreticalSFDR=6*obj.NumQuantizerAccumulatorBits+12;
                else
                    s.TheoreticalSFDR=6*obj.NumQuantizerAccumulatorBits;
                end
            else
                s.NumPointsLUT=2^(obj.CustomAccumulatorDataType.WordLength-2)+1;
                s.SineLUTSize=...
                round(s.NumPointsLUT*getOutputWordLength(obj,obj.OutputDataType)/8);
            end
            s.FrequencyResolution=1/2^obj.CustomAccumulatorDataType.WordLength;
        end
    end

    methods(Hidden)
        function setParameters(obj)
            PhaseIncrementSourceIdx=getIndex(...
            obj.PhaseIncrementSourceSet,obj.PhaseIncrementSource);
            PhaseOffsetSourceIdx=getIndex(...
            obj.PhaseOffsetSourceSet,obj.PhaseOffsetSource);
            WaveformIdx=getIndex(...
            obj.WaveformSet,obj.Waveform);
            OutputDataTypeIdx=getIndex(...
            obj.OutputDataTypeSet,obj.OutputDataType);
            AccumWordLength=obj.CustomAccumulatorDataType.WordLength;
            OutputWordLength=obj.CustomOutputDataType.WordLength;
            OutputFractionalLength=obj.CustomOutputDataType.FractionLength;

            coder.internal.errorIf(~isfixptinstalled&&...
            strcmp(obj.OutputDataType,matlab.system.getSpecifyString('scaled')),...
            'dsp:system:NCO:fixptTbxRq',matlab.system.getSpecifyString('scaled'),'double','single');


            if PhaseIncrementSourceIdx==2
                setFrameStatus(obj,false);
            else
                setFrameStatus(obj,true);
            end

            obj.compSetParameters({...
            PhaseIncrementSourceIdx,...
            obj.PhaseIncrement,...
            PhaseOffsetSourceIdx,...
            obj.PhaseOffset,...
            AccumWordLength,...
            double(obj.PhaseQuantizationErrorOutputPort),...
            double(obj.Dither),...
            obj.NumDitherBits,...
            obj.PNGeneratorLength,...
            WaveformIdx,...
            OutputDataTypeIdx,...
            OutputWordLength,...
            OutputFractionalLength,...
            1,...
            double(obj.PhaseQuantization),...
            obj.NumQuantizerAccumulatorBits,...
            1,...
            obj.SamplesPerFrame...
            ,1,...
            });
        end
    end

    methods(Access=protected)


        function flag=isInactivePropertyImpl(obj,prop)
            flag=false;
            switch prop
            case 'PhaseIncrement'
                if strcmp(obj.PhaseIncrementSource,'Input port')
                    flag=true;
                end
            case{'PhaseOffset','SamplesPerFrame'}
                if strcmp(obj.PhaseOffsetSource,'Input port')
                    flag=true;
                end
            case 'NumDitherBits'
                if~obj.Dither
                    flag=true;
                end
            case{'NumQuantizerAccumulatorBits','PhaseQuantizationErrorOutputPort'}
                if~obj.PhaseQuantization
                    flag=true;
                end
            case 'CustomOutputDataType'
                if~strcmp(obj.OutputDataType,matlab.system.getSpecifyString('scaled'))
                    flag=true;
                end
            end
        end
    end

    methods(Access=private)
        function outputWordLength=getOutputWordLength(obj,OM)
            if matlab.system.isSpecifiedTypeMode(OM)
                outputWordLength=obj.CustomOutputDataType.WordLength;
            elseif strcmp(OM,'single')
                outputWordLength=32;
            elseif strcmp(OM,'double')
                outputWordLength=64;
            else
                coder.internal.assert(false,'dsp:system:NCO:invalidOutputMode');
            end
        end
    end

    methods(Static)
        function helpFixedPoint




            matlab.system.dispFixptHelp('dsp.NCO',dsp.NCO.getDisplayFixedPointPropertiesImpl);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='dspsigops/NCO';
        end

        function props=getDisplayPropertiesImpl()
            props={...
            'PhaseIncrementSource',...
'PhaseIncrement'...
            ,'PhaseOffsetSource'...
            ,'PhaseOffset'...
            ,'Dither'...
            ,'NumDitherBits'...
            ,'PhaseQuantization'...
            ,'NumQuantizerAccumulatorBits'...
            ,'PhaseQuantizationErrorOutputPort'...
            ,'Waveform'...
            ,'SamplesPerFrame'...
            ,'OutputDataType',...
            };
        end

        function props=getDisplayFixedPointPropertiesImpl()
            props={...
            'RoundingMethod','OverflowAction'...
            ,'AccumulatorDataType','CustomAccumulatorDataType',...
'CustomOutputDataType'
            };
        end

        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end

end



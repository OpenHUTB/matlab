classdef IFFT<matlab.system.SFunSystem



















































































%#function mdspfft2

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)




        FFTImplementation='Auto';






        FFTLengthSource='Auto';







        FFTLength=64;








        RoundingMethod='Floor';




        OverflowAction='Wrap';





        SineTableDataType='Same word length as input';








        CustomSineTableDataType=numerictype([],16);





        ProductDataType='Full precision';








        CustomProductDataType=numerictype([],32,30);





        AccumulatorDataType='Full precision';








        CustomAccumulatorDataType=numerictype([],32,30);





        OutputDataType='Full precision';








        CustomOutputDataType=numerictype([],16,15);










        BitReversedInput(1,1)logical=false;











        ConjugateSymmetricInput(1,1)logical=false;




        Normalize(1,1)logical=true;






        WrapInput(1,1)logical=true;
    end

    properties(Constant,Hidden)
        FFTImplementationSet=dsp.CommonSets.getSet('FFTImplementation');
        TwiddleFactorComputationSet=dsp.CommonSets.getSet(...
        'SineComputation');
        TableOptimizationSet=matlab.system.StringSet({'Speed','Memory'});
        FFTLengthSourceSet=dsp.CommonSets.getSet('AutoOrProperty');

        RoundingMethodSet=dsp.CommonSets.getSet('RoundingMethod');
        OverflowActionSet=dsp.CommonSets.getSet('OverflowAction');
        SineTableDataTypeSet=dsp.CommonSets.getSet(...
        'FixptModeUnscaled');
        ProductDataTypeSet=dsp.CommonSets.getSet('FixptModeInherit');
        AccumulatorDataTypeSet=dsp.CommonSets.getSet(...
        'FixptModeInheritProd');
        OutputDataTypeSet=dsp.CommonSets.getSet('FixptModeInherit');
    end

    properties(Hidden,Nontunable)


        TwiddleFactorComputation='Table lookup';
        TableOptimization='Speed';
    end

    methods

        function obj=IFFT(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mdspfft2');
            setProperties(obj,nargin,varargin{:});
            setEmptyAllowedStatus(obj,true);
        end

        function set.CustomSineTableDataType(obj,val)
            validateCustomDataType(obj,'CustomSineTableDataType',val,...
            {'AUTOSIGNED','NOTSCALED'});
            obj.CustomSineTableDataType=val;
        end
        function set.CustomProductDataType(obj,val)
            validateCustomDataType(obj,'CustomProductDataType',val,...
            {'AUTOSIGNED','SCALED'});
            obj.CustomProductDataType=val;
        end
        function set.CustomAccumulatorDataType(obj,val)
            validateCustomDataType(obj,'CustomAccumulatorDataType',val,...
            {'AUTOSIGNED','SCALED'});
            obj.CustomAccumulatorDataType=val;
        end
        function set.CustomOutputDataType(obj,val)
            validateCustomDataType(obj,'CustomOutputDataType',val,...
            {'AUTOSIGNED','SCALED'});
            obj.CustomOutputDataType=val;
        end

    end

    methods(Hidden)
        function setParameters(obj)


            FFTImplementationIdx=getIndex(obj.FFTImplementationSet,...
            obj.FFTImplementation);
            inheritFFTLength=double(strcmp(obj.FFTLengthSource,'Auto'));

            if isSizesOnlyCall(obj)
                obj.compSetParameters({...
                1,...
                2,...
                4,...
                1,...
                double(obj.BitReversedInput),...
                double(obj.ConjugateSymmetricInput),...
                double(obj.Normalize),...
                0,...
                inheritFFTLength,...
                obj.FFTLength,...
                double(obj.WrapInput),...
                1,...
                [],...
                [],...
                1,...
                dspfftcontrol,...
                FFTImplementationIdx,...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
1...
                });
            else
                dtInfo=getFixptDataTypeInfo(obj,...
                {'SineTable','Product','Accumulator','Output'});

                obj.compSetParameters({...
                1,...
                2,...
                4,...
                1,...
                double(obj.BitReversedInput),...
                double(obj.ConjugateSymmetricInput),...
                double(obj.Normalize),...
                0,...
                inheritFFTLength,...
                obj.FFTLength,...
                double(obj.WrapInput),...
                1,...
                [],...
                [],...
                1,...
                dspfftcontrol,...
                FFTImplementationIdx,...
                dtInfo.SineTableDataType,...
                dtInfo.SineTableWordLength,...
                dtInfo.SineTableFracLength,...
                dtInfo.ProductDataType,...
                dtInfo.ProductWordLength,...
                dtInfo.ProductFracLength,...
                dtInfo.AccumulatorDataType,...
                dtInfo.AccumulatorWordLength,...
                dtInfo.AccumulatorFracLength,...
                dtInfo.OutputDataType,...
                dtInfo.OutputWordLength,...
                dtInfo.OutputFracLength,...
                dtInfo.RoundingMethod,...
                dtInfo.OverflowAction...
                });
            end
        end

    end

    methods(Access=protected)

        function flag=isInactivePropertyImpl(obj,prop)
            flag=false;
            switch prop
            case obj.getDisplayFixedPointPropertiesImpl
                if strcmp(obj.FFTImplementation,'FFTW')
                    flag=true;
                end
            case 'BitReversedInput'
                if strcmp(obj.FFTImplementation,'FFTW')||...
                    (~(obj.BitReversedInput||obj.ConjugateSymmetricInput)&&...
                    ~strcmp(obj.FFTLengthSource,'Auto')&&...
                    strcmp(obj.FFTLengthSource,'Property'))
                    flag=true;
                end
            case 'CustomSineTableDataType'
                if~strcmp(obj.FFTImplementation,'FFTW')&&...
                    ~matlab.system.isSpecifiedTypeMode(obj.SineTableDataType)
                    flag=true;
                end
            case 'CustomProductDataType'
                if~strcmp(obj.FFTImplementation,'FFTW')&&...
                    ~matlab.system.isSpecifiedTypeMode(obj.ProductDataType)
                    flag=true;
                end
            case 'CustomAccumulatorDataType'
                if~strcmp(obj.FFTImplementation,'FFTW')&&...
                    ~matlab.system.isSpecifiedTypeMode(obj.AccumulatorDataType)
                    flag=true;
                end
            case 'CustomOutputDataType'
                if~strcmp(obj.FFTImplementation,'FFTW')&&...
                    ~matlab.system.isSpecifiedTypeMode(obj.OutputDataType)
                    flag=true;
                end
            case 'FFTLengthSource'
                if obj.BitReversedInput||obj.ConjugateSymmetricInput
                    flag=true;
                end
            case{'FFTLength','WrapInput'}
                if obj.BitReversedInput||obj.ConjugateSymmetricInput||...
                    strcmp(obj.FFTLengthSource,'Auto')
                    flag=true;
                end
            case 'ConjugateSymmetricInput'
                if~(obj.BitReversedInput||obj.ConjugateSymmetricInput)&&...
                    ~strcmp(obj.FFTLengthSource,'Auto')&&...
                    strcmp(obj.FFTLengthSource,'Property')
                    flag=true;
                end
            end
        end
    end

    methods(Static)
        function helpFixedPoint






            matlab.system.dispFixptHelp('dsp.IFFT',...
            dsp.IFFT.getDisplayFixedPointPropertiesImpl);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='dspxfrm3/IFFT';
        end


        function props=getDisplayPropertiesImpl()
            props={...
            'FFTImplementation',...
'BitReversedInput'...
            ,'ConjugateSymmetricInput',...
'Normalize'...
            ,'FFTLengthSource'...
            ,'FFTLength'...
            ,'WrapInput'
            };
        end

        function props=getDisplayFixedPointPropertiesImpl()
            props={...
            'RoundingMethod','OverflowAction',...
            'SineTableDataType','CustomSineTableDataType'...
            ,'ProductDataType','CustomProductDataType'...
            ,'AccumulatorDataType','CustomAccumulatorDataType'...
            ,'OutputDataType','CustomOutputDataType'...
            };
        end
        function y=allocatePortBuffersInCodegen




            y=true;
        end
    end

    methods(Access=protected)
        function setPortDataTypeConnections(obj)
            setPortDataTypeConnection(obj,1,1);
        end
    end

end

classdef FIRInterpolator<dsp.internal.AutoDesignMultirateFIR
















































































































%#function mdspupfir2

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Constant,Access=protected)


        DefaultNumerator=designMultirateFIR(3,1);
        DefaultLegacyNumerator=fir1(15,0.25);
        DefaultFdesign=fdesign.interpolator(3,'Nyquist',3,'N,Ast',length(designMultirateFIR(3,1)),80);
    end


    properties(Nontunable)




        InterpolationFactor=3;




        NumeratorSource='Property';




        DesignMethod='Kaiser';






        RoundingMethod='Floor';





        OverflowAction='Wrap';






        CoefficientsDataType='Same word length as input';









        CustomCoefficientsDataType=numerictype([],16,15);






        ProductDataType='Full precision';









        CustomProductDataType=numerictype([],32,30);






        AccumulatorDataType='Full precision';









        CustomAccumulatorDataType=numerictype([],32,30);






        OutputDataType='Same as accumulator';









        CustomOutputDataType=numerictype([],16,15);
















        FullPrecisionOverride(1,1)logical=true;
    end

    properties(Nontunable,Hidden)




        RateOptions='Enforce single-rate processing';





        EnableMultiChannelParallelism(1,1)logical=true;






        CoderTarget='MATLAB';

    end

    properties(Constant,Hidden)
        RateOptionsSet=matlab.system.StringSet({'Enforce single-rate processing',...
        'Allow multirate processing'});
        NumeratorSourceSet=matlab.system.StringSet({'Property','Input port','Auto'});
        DesignMethodSet=matlab.system.StringSet({'ZOH','Linear','Kaiser'});

        RoundingMethodSet=dsp.CommonSets.getSet('RoundingMethod');
        OverflowActionSet=dsp.CommonSets.getSet('OverflowAction');
        CoefficientsDataTypeSet=dsp.CommonSets.getSet('FixptModeEitherScale');
        ProductDataTypeSet=dsp.CommonSets.getSet('FixptModeInherit');
        AccumulatorDataTypeSet=dsp.CommonSets.getSet('FixptModeInheritProd');
        OutputDataTypeSet=dsp.CommonSets.getSet('FixptModeAccumProd');
    end

    methods

        function obj=FIRInterpolator(varargin)
            coder.allowpcode('plain');
            obj@dsp.internal.AutoDesignMultirateFIR('mdspupfir2');

            obj.parseInputArguments(varargin{:});

            setEmptyAllowedStatus(obj,true);
        end

        function fdhdltool(obj,InputNumericType)
























            if~exist('InputNumericType','var')
                error(message('hdlfilter:privgeneratehdl:fdhdltoolinputdatatypenotspecified'));
            end

            errIfNotValidCoeffSource(obj);
            firinterp=sysobjHdl(obj,'InputDataType',InputNumericType);
            fdhdltool(firinterp,'InputDataType',InputNumericType);
        end

        function generatehdl(obj,varargin)

















            for k=1:length(varargin)
                if iscell(varargin{k})
                    [varargin{k}{:}]=convertStringsToChars(varargin{k}{:});
                else
                    varargin{k}=convertStringsToChars(varargin{k});
                end
            end

            errIfNotValidCoeffSource(obj);
            firinterp=sysobjHdl(obj,varargin{:});

            generatehdl(firinterp,varargin{:});

        end

        function set.NumeratorSource(obj,val)
            clearMetaData(obj)
            obj.NumeratorSource=val;
        end

        function set.DesignMethod(obj,val)
            clearMetaData(obj)
            obj.DesignMethod=val;
            obj.invalidateNumerator();
        end

        function set.InterpolationFactor(obj,value)
            validateattributes(value,{'numeric'},...
            {'positive','integer','scalar'},'','InterpolationFactor');
            clearMetaData(obj)
            obj.InterpolationFactor=value;
            obj.invalidateNumerator();
        end

        function set.RateOptions(obj,val)
            obj.RateOptions=val;
        end

        function set.EnableMultiChannelParallelism(obj,val)
            validateattributes(val,{'logical'},{'scalar'});
            obj.EnableMultiChannelParallelism=val;
        end

        function set.CoderTarget(obj,val)
            obj.CoderTarget=val;
        end

        function set.CustomCoefficientsDataType(obj,val)
            validateCustomDataType(obj,'CustomCoefficientsDataType',val,...
            getFixedPointRestrictions(obj,'CustomCoefficientsDataType'));
            obj.CustomCoefficientsDataType=val;
        end

        function set.CustomProductDataType(obj,val)
            validateCustomDataType(obj,'CustomProductDataType',val,...
            getFixedPointRestrictions(obj,'CustomProductDataType'));
            obj.CustomProductDataType=val;
        end

        function set.CustomAccumulatorDataType(obj,val)
            validateCustomDataType(obj,'CustomAccumulatorDataType',val,...
            getFixedPointRestrictions(obj,'CustomAccumulatorDataType'));
            obj.CustomAccumulatorDataType=val;
        end

        function set.CustomOutputDataType(obj,val)
            validateCustomDataType(obj,'CustomOutputDataType',val,...
            getFixedPointRestrictions(obj,'CustomOutputDataType'));
            obj.CustomOutputDataType=val;
        end
    end

    methods(Hidden,Access=public)
        function dtInfo=getFixedPointInfo(obj)
            dtInfo=getFixptDataTypeInfo(obj,...
            {'Coefficients','Product','Accumulator','Output'});
        end
    end

    methods(Hidden)

        function setParameters(obj)
            L=obj.InterpolationFactor;
            NumeratorSourceIdx=getIndex(obj.NumeratorSourceSet,obj.NumeratorSource);
            h=obj.Numerator;




            if(NumeratorSourceIdx~=2)
                filterDefined=~(isempty(h)||isempty(L));
                if filterDefined

                    len=length(h);
                    if(rem(len,L)~=0)
                        nzeros=L-rem(len,L);
                        h=[h(:);zeros(nzeros,1)];
                    end
                    len=length(h);
                    nrows=len/L;

                    h=reshape(h,L,nrows).';
                end
            end

            rateOptionIdx=getIndex(obj.RateOptionsSet,obj.RateOptions);
            isCodegenForSim=double(coder.const(dsp.enhancedsim.IsSysObjSimInCodeGen(...
            obj.CoderTarget)));

            if isSizesOnlyCall(obj)
                obj.compSetParameters({...
                NumeratorSourceIdx,...
                h,...
                L,...
                rateOptionIdx,...
                1,...
                0,...
                0,...
                16,...
                15,...
                [],...
                [],...
                [],...
                [],...
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
                3,...
                1,...
                double(obj.EnableMultiChannelParallelism),...
isCodegenForSim...
                });
            else
                dtInfo=getFixptDataTypeInfo(obj,...
                {'Coefficients','Product','Accumulator','Output'});

                if obj.FullPrecisionOverride
                    obj.compSetParameters({...
                    NumeratorSourceIdx,...
                    h,...
                    L,...
                    rateOptionIdx,...
                    1,...
                    0,...
                    0,...
                    16,...
                    15,...
                    [],...
                    [],...
                    [],...
                    [],...
                    dtInfo.CoefficientsDataType,...
                    dtInfo.CoefficientsWordLength,...
                    dtInfo.CoefficientsFracLength,...
                    5,...
                    2,...
                    2,...
                    5,...
                    2,...
                    2,...
                    4,...
                    2,...
                    2,...
                    3,...
                    1,...
                    double(obj.EnableMultiChannelParallelism),...
isCodegenForSim...
                    });
                else
                    obj.compSetParameters({...
                    NumeratorSourceIdx,...
                    h,...
                    L,...
                    rateOptionIdx,...
                    1,...
                    0,...
                    0,...
                    16,...
                    15,...
                    [],...
                    [],...
                    [],...
                    [],...
                    dtInfo.CoefficientsDataType,...
                    dtInfo.CoefficientsWordLength,...
                    dtInfo.CoefficientsFracLength,...
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
                    dtInfo.OverflowAction,...
                    double(obj.EnableMultiChannelParallelism),...
isCodegenForSim...
                    });
                end
            end
        end

        function restrictionsCell=getFixedPointRestrictions(obj,prop)
            restrictionsCell={};
            switch prop
            case{'CustomProductDataType',...
                'CustomAccumulatorDataType',...
                'CustomOutputDataType'}
                restrictionsCell={'AUTOSIGNED','SCALED'};
            case{'CustomCoefficientsDataType'}
                restrictionsCell={'AUTOSIGNED'};
            otherwise
                coder.internal.assert(false,...
                'dsp:dsp:private:FilterSystemObjectBase:InvalidProperty',prop,class(obj));
            end
        end
        function props=getNonFixedPointProperties(~)
            props=dsp.FIRInterpolator.getDisplayPropertiesImpl;
        end
        function props=getFixedPointProperties(~)
            props=dsp.FIRInterpolator.getDisplayFixedPointPropertiesImpl;
        end
        function flag=isPropertyActive(obj,prop)
            flag=~isInactivePropertyImpl(obj,prop);
        end
        function y=supportsUnboundedIO(~)
            y=true;
        end
    end

    methods(Access=protected)
        function parseInputArguments(obj,varargin)



            if nargin==1

                obj.Numerator=obj.DefaultNumerator;
                obj.setMetaData(obj.DefaultFdesign,fdfmethod.kaiserhbastop,[],'kaiserwin');
                return;
            end


            if(ischar(varargin{end})||isstring(varargin{end}))&&strcmpi(varargin{end},'legacy')

                obj.Numerator=obj.DefaultLegacyNumerator;
                setProperties(obj,nargin-2,varargin{1:end-1},'InterpolationFactor','Numerator');
                return;
            end

            nargs=nargin-1;


            numeratorSpecifiedPV=any(cellfun(@(x)(isstring(x)||ischar(x))&&x=="Numerator",varargin));


            if nargs==1
                setProperties(obj,nargs,varargin{:},'InterpolationFactor');

                if isnumeric(varargin{1})
                    obj.designFIRFilter();
                end
                return;
            end




            if isprop(obj,varargin{1})
                setProperties(obj,nargs,varargin{:});





                if strcmpi(obj.NumeratorSource,'Property')&&~numeratorSpecifiedPV
                    obj.designFIRFilter();
                end
                return;
            end




            if isnumeric(varargin{2})
                setProperties(obj,nargs,varargin{:},'InterpolationFactor','Numerator');
                return;
            end







            if any(strcmpi({'auto','zoh','linear','kaiser'},varargin{2}))
                if lower(varargin{2})=="auto"
                    args={varargin{1},'NumeratorSource',varargin{2:end}};
                else
                    args={varargin{1},'NumeratorSource','Auto','DesignMethod',varargin{2:end}};
                end
                setProperties(obj,length(args),args{:},'InterpolationFactor');


                return;
            end



            if~isprop(obj,varargin{2})

                coder.internal.error('dsp:system:AutoDesignMultirateFIR:invalidNumeratorArgument');
            end
            setProperties(obj,nargs,varargin{:},'InterpolationFactor');


            if~numeratorSpecifiedPV&&strcmpi(obj.NumeratorSource,'Property')
                obj.designFIRFilter();
            end
        end

        function validateInputsImpl(obj,varargin)

            if~isempty(varargin)
                inputData=varargin{1};
                cacheInputDataType(obj,inputData)
            end
        end

        function flag=isInactivePropertyImpl(obj,prop)
            flag=false;
            switch prop
            case{'RoundingMethod','OverflowAction'}
                if(obj.FullPrecisionOverride||...
                    (strcmpi(obj.OutputDataType,'Same as accumulator')&&...
                    strcmpi(obj.ProductDataType,'Full precision')&&...
                    strcmpi(obj.AccumulatorDataType,'Full precision')))
                    flag=true;
                end
            case{'ProductDataType','AccumulatorDataType','OutputDataType'}
                if obj.FullPrecisionOverride
                    flag=true;
                end
            case 'CustomProductDataType'
                if(obj.FullPrecisionOverride||...
                    (strcmpi(obj.OutputDataType,'Same as accumulator')&&...
                    strcmpi(obj.ProductDataType,'Full precision')&&...
                    strcmpi(obj.AccumulatorDataType,'Full precision'))||...
                    ~matlab.system.isSpecifiedTypeMode(obj.ProductDataType))
                    flag=true;
                end
            case 'CustomAccumulatorDataType'
                if(obj.FullPrecisionOverride||...
                    (strcmpi(obj.OutputDataType,'Same as accumulator')&&...
                    strcmpi(obj.ProductDataType,'Full precision')&&...
                    strcmpi(obj.AccumulatorDataType,'Full precision'))||...
                    ~matlab.system.isSpecifiedTypeMode(obj.AccumulatorDataType))
                    flag=true;
                end
            case 'CustomOutputDataType'
                if(obj.FullPrecisionOverride||...
                    (strcmpi(obj.OutputDataType,'Same as accumulator')&&...
                    strcmpi(obj.ProductDataType,'Full precision')&&...
                    strcmpi(obj.AccumulatorDataType,'Full precision'))||...
                    ~matlab.system.isSpecifiedTypeMode(obj.OutputDataType))
                    flag=true;
                end
            case 'CustomCoefficientsDataType'
                if(strcmp(obj.NumeratorSource,'Input port')||...
                    ~matlab.system.isSpecifiedTypeMode(obj.CoefficientsDataType))
                    flag=true;
                end
            case 'CoefficientsDataType'
                flag=any(strcmpi('Input Port',obj.NumeratorSource));

            otherwise
                flag=isInactivePropertyImpl@dsp.internal.AutoDesignMultirateFIR(obj,prop);
            end
        end

        function d=convertToDFILT(obj,arith)



            if~strcmp(obj.NumeratorSource,{'Property','Auto'})
                sendNoAvailableCoefficientsError(obj,'NumeratorSource');
            end

            d=dsp.internal.mfilt.firinterp;
            d.InterpolationFactor=obj.InterpolationFactor;
            d.Numerator=obj.Numerator;
            d.Arithmetic=arith;
            d.PersistentMemory=true;

            if strcmpi(arith,'fixed')
                if strcmp(obj.CoefficientsDataType,'Custom')
                    coeffNumericType=obj.CustomCoefficientsDataType;
                else
                    coeffNumericType=getCoefficientsDataType(obj,'fir',...
                    'CoefficientsDataType');
                end
                d.CoeffWordLength=coeffNumericType.WordLength;
                if isbinarypointscalingset(coeffNumericType)
                    d.CoeffAutoScale=false;
                    d.NumFracLength=coeffNumericType.FractionLength;
                end

                if isLocked(obj)
                    fixedpointinfo=getCompiledFixedPointInfo(obj);
                    d.FilterInternals='SpecifyPrecision';

                    d.OutputWordLength=fixedpointinfo.OutputDataType.WordLength;
                    d.OutputFracLength=fixedpointinfo.OutputDataType.FractionLength;

                    d.ProductWordLength=fixedpointinfo.ProductDataType.WordLength;
                    d.ProductFracLength=fixedpointinfo.ProductDataType.FractionLength;

                    d.AccumWordLength=fixedpointinfo.AccumulatorDataType.WordLength;
                    d.AccumFracLength=fixedpointinfo.AccumulatorDataType.FractionLength;

                    switch obj.RoundingMethod
                    case 'Ceiling'
                        d.RoundMode='ceil';
                    case 'Convergent'
                        d.RoundMode='convergent';
                    case{'Floor','Simplest'}
                        d.RoundMode='floor';
                    case 'Nearest'
                        d.RoundMode='nearest';
                    case 'Round'
                        d.RoundMode='round';
                    case 'Zero'
                        d.RoundMode='fix';
                    end
                    d.OverflowMode=obj.OverflowAction;
                end

            end
        end

    end

    methods(Static)
        function helpFixedPoint






            matlab.system.dispFixptHelp('dsp.FIRInterpolator',dsp.FIRInterpolator.getDisplayFixedPointPropertiesImpl);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='dspmlti4/FIR Interpolation';
        end

        function props=getDisplayPropertiesImpl()
            props={...
'InterpolationFactor'...
            ,'NumeratorSource',...
            'DesignMethod',...
            'Numerator',...
            };
        end

        function props=getDisplayFixedPointPropertiesImpl()
            props={...
            'FullPrecisionOverride',...
            'RoundingMethod','OverflowAction',...
            'CoefficientsDataType','CustomCoefficientsDataType',...
            'ProductDataType','CustomProductDataType',...
            'AccumulatorDataType','CustomAccumulatorDataType',...
            'OutputDataType','CustomOutputDataType'};
        end


        function props=getValueOnlyProperties()
            props={'InterpolationFactor','Numerator','NumeratorSource','DesignMethod'};
        end
        function y=hasEmptyGeneratedTerminateFcn()




            y=false;
        end
    end

    methods(Access=protected)
        function setPortDataTypeConnections(obj)
            setPortDataTypeConnection(obj,1,1);
        end
    end

    methods(Hidden)
        function[L,M]=rateConversionFactors(obj,forceGCDReduction)%#ok
            L=obj.InterpolationFactor;
            M=1;
        end
    end

end

function errIfNotValidCoeffSource(obj)
    if strcmp(obj.NumeratorSource,'Input port')
        error(message('dsp:dsp:private:FilterSystemObjectBase:HDLFIRInputPortError'));
    end
end

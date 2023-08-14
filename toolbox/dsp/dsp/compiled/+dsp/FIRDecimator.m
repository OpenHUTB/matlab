classdef FIRDecimator<dsp.internal.AutoDesignMultirateFIR











































































































%#function mdspfirdn2

    properties(Constant,Access=protected)


        DefaultNumerator=designMultirateFIR(1,2);
        DefaultLegacyNumerator=fir1(35,0.4);
        DefaultFdesign=fdesign.decimator(2,'Nyquist',2,'N,Ast',length(designMultirateFIR(1,2)),80);
    end

    properties(Constant,Hidden)



        DesignMethod='Kaiser';
    end

    properties(Nontunable)





        DecimationFactor=2;




        NumeratorSource='Property';




        Structure='Direct form';






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










        AllowArbitraryInputLength(1,1)logical=false;
    end

    properties(Nontunable,Hidden)




        DecimationOffset=0;




        RateOptions='Enforce single-rate processing';





        CoderTarget='MATLAB';
    end

    properties(Constant,Hidden)
        StructureSet=matlab.system.StringSet({'Direct form','Direct form transposed'});
        RateOptionsSet=matlab.system.StringSet({'Enforce single-rate processing',...
        'Allow multirate processing'});
        NumeratorSourceSet=matlab.system.StringSet({'Property','Input port','Auto'});


        RoundingMethodSet=dsp.CommonSets.getSet('RoundingMethod');
        OverflowActionSet=dsp.CommonSets.getSet('OverflowAction');
        CoefficientsDataTypeSet=dsp.CommonSets.getSet('FixptModeEitherScale');
        ProductDataTypeSet=dsp.CommonSets.getSet('FixptModeInherit');
        AccumulatorDataTypeSet=dsp.CommonSets.getSet('FixptModeInheritProd');
        OutputDataTypeSet=dsp.CommonSets.getSet('FixptModeAccumProd');
    end

    methods
        function obj=FIRDecimator(varargin)
            coder.allowpcode('plain');
            obj@dsp.internal.AutoDesignMultirateFIR('mdspfirdn2');

            obj.parseInputArguments(varargin{:});


            setEmptyAllowedStatus(obj,true);



            setFrameStatus(obj,true);
        end

        function fdhdltool(obj,InputNumericType)
























            if~exist('InputNumericType','var')
                error(message('hdlfilter:privgeneratehdl:fdhdltoolinputdatatypenotspecified'));
            end

            errIfNotValidCoeffSource(obj);
            firdecim=sysobjHdl(obj,'InputDataType',InputNumericType);
            fdhdltool(firdecim,'InputDataType',InputNumericType);
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
            firdecim=sysobjHdl(obj,varargin{:});

            generatehdl(firdecim,varargin{:});

        end

        function set.NumeratorSource(obj,val)
            clearMetaData(obj)
            obj.NumeratorSource=val;
        end

        function set.Structure(obj,val)
            clearMetaData(obj)
            obj.Structure=val;
        end

        function set.RateOptions(obj,val)
            obj.RateOptions=val;
        end

        function set.CoderTarget(obj,val)
            obj.CoderTarget=val;
        end

        function set.AllowArbitraryInputLength(obj,val)
            validateattributes(val,{'logical'},{'scalar'},'','AllowArbitraryInputLength');
            obj.AllowArbitraryInputLength=val;
        end

        function set.DecimationFactor(obj,value)
            validateattributes(value,{'numeric'},...
            {'positive','integer','scalar'},'','DecimationFactor');
            clearMetaData(obj)
            obj.DecimationFactor=value;
            obj.invalidateNumerator();
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
            FilterStructureIdx=getIndex(obj.StructureSet,obj.Structure);
            rateOptionIdx=getIndex(obj.RateOptionsSet,obj.RateOptions);
            isCodegenForSim=double(coder.const(dsp.enhancedsim.IsSysObjSimInCodeGen(...
            obj.CoderTarget)));
            enableArbitrary=obj.AllowArbitraryInputLength;


            h=obj.Numerator;
            D=obj.DecimationFactor;

            NumeratorSourceIdx=getIndex(obj.NumeratorSourceSet,...
            obj.NumeratorSource);


            if(NumeratorSourceIdx~=2)
                filterDefined=~(isempty(h)||isempty(D));
                if filterDefined
                    if(FilterStructureIdx==1)


                        len=length(h);
                        h=flipud(h(:));
                        if(rem(len,D)~=0)
                            nzeros=D-rem(len,D);
                            h=[zeros(nzeros,1);h];
                        end
                        len=length(h);
                        nrows=len/D;

                        h=flipud(reshape(h,D,nrows).');
                    else


                        len=length(h);
                        if(rem(len,D)~=0)
                            nzeros=D-rem(len,D);
                            h=[h,zeros(1,nzeros)];
                        end
                        len=length(h);
                        nrows=len/D;

                        h=reshape(h,D,nrows).';
                    end
                end
            end

            reshuffledNumerator=h;
            if isSizesOnlyCall(obj)
                obj.compSetParameters({...
                NumeratorSourceIdx,...
                reshuffledNumerator,...
                obj.DecimationFactor,...
                rateOptionIdx,...
                1,...
                obj.DecimationOffset,...
                0,...
                FilterStructureIdx,...
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
                double(enableArbitrary),...
isCodegenForSim...
                });
            else
                dtInfo=getFixptDataTypeInfo(obj,...
                {'Coefficients','Product','Accumulator','Output'});

                if obj.FullPrecisionOverride
                    obj.compSetParameters({...
                    NumeratorSourceIdx,...
                    reshuffledNumerator,...
                    obj.DecimationFactor,...
                    rateOptionIdx,...
                    1,...
                    obj.DecimationOffset,...
                    0,...
                    FilterStructureIdx,...
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
                    double(enableArbitrary),...
isCodegenForSim...
                    });
                else
                    obj.compSetParameters({...
                    NumeratorSourceIdx,...
                    reshuffledNumerator,...
                    obj.DecimationFactor,...
                    rateOptionIdx,...
                    1,...
                    obj.DecimationOffset,...
                    0,...
                    FilterStructureIdx,...
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
                    double(enableArbitrary),...
isCodegenForSim...
                    });
                end
            end
        end

        function y=supportsUnboundedIO(~)
            y=true;
        end
        function restrictionsCell=getFixedPointRestrictions(obj,prop)
            switch prop
            case{'CustomProductDataType',...
                'CustomAccumulatorDataType',...
                'CustomOutputDataType'}
                restrictionsCell={'AUTOSIGNED','SCALED'};
            case{'CustomCoefficientsDataType'}
                restrictionsCell={'AUTOSIGNED'};
            otherwise
                error(message(...
                'dsp:dsp:private:FilterSystemObjectBase:InvalidProperty',prop,class(obj)))
            end
        end
        function props=getNonFixedPointProperties(~)
            props=dsp.FIRDecimator.getDisplayPropertiesList;
        end
        function props=getFixedPointProperties(~)
            props=dsp.FIRDecimator.getDisplayFixedPointPropertiesList;
        end
        function flag=isPropertyActive(obj,prop)
            flag=~isInactivePropertyImpl(obj,prop);
        end
    end

    methods(Access=protected)
        function parseInputArguments(obj,varargin)



            if nargin==1

                obj.Numerator=obj.DefaultNumerator;
                obj.setMetaData(obj.DefaultFdesign,fdfmethod.kaiserhbastop,[],'kaiserwin');
                return
            end


            if(ischar(varargin{end})||isstring(varargin{end}))&&strcmpi(varargin{end},'legacy')

                obj.Numerator=obj.DefaultLegacyNumerator;
                setProperties(obj,nargin-2,varargin{1:end-1},'DecimationFactor','Numerator');
                return;
            end


            nargs=nargin-1;

            numeratorSpecifiedPV=any(cellfun(@(x)(isstring(x)||ischar(x))&&x=="Numerator",varargin));


            if nargs==1
                setProperties(obj,nargs,varargin{:},'DecimationFactor');


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
                setProperties(obj,nargs,varargin{:},'DecimationFactor','Numerator');
                return
            end



            if any(strcmpi('auto',varargin{2}))
                args={varargin{1},'NumeratorSource',varargin{2:end}};
                setProperties(obj,length(args),args{:},'DecimationFactor');
                return
            end


            if~isprop(obj,varargin{2})


                coder.internal.error('dsp:system:AutoDesignMultirateFIR:invalidNumeratorArgument');
            end

            setProperties(obj,nargs,varargin{:},'DecimationFactor');

            if strcmpi(obj.NumeratorSource,'Property')&&~numeratorSpecifiedPV
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
            switch prop
            case{'RoundingMethod','OverflowAction'}
                flag=(obj.FullPrecisionOverride||...
                (strcmpi(obj.OutputDataType,'Same as accumulator')&&...
                strcmpi(obj.ProductDataType,'Full precision')&&...
                strcmpi(obj.AccumulatorDataType,'Full precision')));

            case{'ProductDataType','AccumulatorDataType','OutputDataType'}
                flag=obj.FullPrecisionOverride;

            case 'CustomProductDataType'
                flag=(obj.FullPrecisionOverride||...
                (strcmpi(obj.OutputDataType,'Same as accumulator')&&...
                strcmpi(obj.ProductDataType,'Full precision')&&...
                strcmpi(obj.AccumulatorDataType,'Full precision'))||...
                ~matlab.system.isSpecifiedTypeMode(obj.ProductDataType));

            case 'CustomAccumulatorDataType'
                flag=(obj.FullPrecisionOverride||...
                (strcmpi(obj.OutputDataType,'Same as accumulator')&&...
                strcmpi(obj.ProductDataType,'Full precision')&&...
                strcmpi(obj.AccumulatorDataType,'Full precision'))||...
                ~matlab.system.isSpecifiedTypeMode(obj.AccumulatorDataType));

            case 'CustomOutputDataType'
                flag=(obj.FullPrecisionOverride||...
                (strcmpi(obj.OutputDataType,'Same as accumulator')&&...
                strcmpi(obj.ProductDataType,'Full precision')&&...
                strcmpi(obj.AccumulatorDataType,'Full precision'))||...
                ~matlab.system.isSpecifiedTypeMode(obj.OutputDataType));

            case 'CustomCoefficientsDataType'
                flag=(strcmp(obj.NumeratorSource,'Input port')||...
                ~matlab.system.isSpecifiedTypeMode(obj.CoefficientsDataType));

            case 'CoefficientsDataType'
                flag=strcmp(obj.NumeratorSource,'Input port');

            otherwise
                flag=isInactivePropertyImpl@dsp.internal.AutoDesignMultirateFIR(obj,prop);

            end
        end

        function d=convertToDFILT(obj,arith)



            if~strcmp(obj.NumeratorSource,{'Property','Auto'})
                sendNoAvailableCoefficientsError(obj,'NumeratorSource');
            end


            w=warning('off','dsp:mfilt:mfilt:Obsolete');
            restoreWarn=onCleanup(@()warning(w));

            if strcmpi(obj.Structure,'Direct form')
                d=mfilt.firdecim;%#ok
            else
                d=mfilt.firtdecim;%#ok
            end

            d.DecimationFactor=obj.DecimationFactor;
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






            matlab.system.dispFixptHelp('dsp.FIRDecimator',dsp.FIRDecimator.getDisplayFixedPointPropertiesList);
        end
    end

    methods(Static,Access=protected)
        function groups=getPropertyGroupsImpl

            propertyListMain=dsp.FIRDecimator.getDisplayPropertiesList;
            propertyListDataType=dsp.FIRDecimator.getDisplayFixedPointPropertiesList;
            propertyListCodegen={'AllowArbitraryInputLength'};

            parameterString=message('dsp:system:Shared:Parameters');

            mainS=matlab.system.display.Section(...
            Title=parameterString.getString,...
            PropertyList=propertyListMain);

            CGs=matlab.system.display.Section(...
            Title=parameterString.getString,...
            PropertyList=propertyListCodegen);

            DTs=matlab.system.display.Section(...
            Title=parameterString.getString,...
            PropertyList=propertyListDataType);

            mainSG=matlab.system.display.SectionGroup(...
            Title=getString(message('dsp:system:Shared:Main')),...
            Sections=mainS);

            cgSG=matlab.system.display.SectionGroup(...
            Title=getString(message('dsp:system:Shared:CodegenProperties')),...
            Sections=CGs);

            dtSG=matlab.system.display.SectionGroup(...
            Title=getString(message('dsp:system:Shared:Datatypes')),...
            Sections=DTs);


            groups=[mainSG,cgSG,dtSG];
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='dspmlti4/FIR Decimation';
        end
        function props=getDisplayPropertiesList()
            props={...
            'DecimationFactor',...
            'NumeratorSource',...
            'Numerator',...
            'Structure'};
        end
        function props=getDisplayFixedPointPropertiesList()
            props={...
            'FullPrecisionOverride',...
            'RoundingMethod','OverflowAction',...
            'CoefficientsDataType','CustomCoefficientsDataType',...
            'ProductDataType','CustomProductDataType',...
            'AccumulatorDataType','CustomAccumulatorDataType',...
            'OutputDataType','CustomOutputDataType'};
        end


        function props=getValueOnlyProperties()
            props={'DecimationFactor','Numerator','NumeratorSource'};
        end

        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end

    methods(Access=protected)
        function setPortDataTypeConnections(obj)
            setPortDataTypeConnection(obj,1,1);
        end

    end

    methods(Hidden)
        function[L,M]=rateConversionFactors(obj,forceGCDReduction)%#ok
            L=1;
            M=obj.DecimationFactor;
        end
    end

end

function errIfNotValidCoeffSource(obj)
    if strcmp(obj.NumeratorSource,'Input port')
        error(message('dsp:dsp:private:FilterSystemObjectBase:HDLFIRInputPortError'));
    end
end

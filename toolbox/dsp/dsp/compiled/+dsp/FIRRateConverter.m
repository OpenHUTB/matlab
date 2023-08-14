classdef FIRRateConverter<dsp.internal.AutoDesignMultirateFIR





































































































































%#function mdspupfirdn2

%#codegen

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Constant,Access=protected)


        DefaultNumerator=designMultirateFIR(3,2);
        DefaultLegacyNumerator=firpm(70,[0,.28,.32,1],[1,1,0,0]);
        DefaultFdesign=fdesign.rsrc(3,2,'Nyquist',3,'N,Ast',length(designMultirateFIR(3,2)),80);
    end


    properties(Nontunable)



        InterpolationFactor=3;




        DecimationFactor=2;




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









        AllowArbitraryInputLength(1,1)logical=false;
    end

    properties(Nontunable,Access=protected)
        FactorsGCD=1;


    end

    properties(Nontunable,Hidden)





        CoderTarget='MATLAB';

    end

    properties(Access=protected,Dependent)





EffectiveInterpolationFactor



EffectiveDecimationFactor



EffectiveNumerator


    end

    methods
        function L=get.EffectiveInterpolationFactor(obj)
            L=double(obj.InterpolationFactor)/obj.FactorsGCD;
        end

        function M=get.EffectiveDecimationFactor(obj)
            M=double(obj.DecimationFactor)/obj.FactorsGCD;
        end

        function num=get.EffectiveNumerator(obj)
            if strcmpi(obj.NumeratorSource,'auto')


                num=obj.Numerator;
            else


                num=obj.Numerator(1:obj.FactorsGCD:end);
            end
        end












    end

    properties(Nontunable)











        FullPrecisionOverride(1,1)logical=true;
    end

    properties(Constant,Hidden)

        NumeratorSourceSet=matlab.system.StringSet({'Property','Auto'});
        DesignMethodSet=matlab.system.StringSet({'ZOH','Linear','Kaiser'});
        RoundingMethodSet=dsp.CommonSets.getSet('RoundingMethod');
        OverflowActionSet=dsp.CommonSets.getSet('OverflowAction');
        CoefficientsDataTypeSet=dsp.CommonSets.getSet('FixptModeEitherScale');
        ProductDataTypeSet=dsp.CommonSets.getSet('FixptModeInherit');
        AccumulatorDataTypeSet=dsp.CommonSets.getSet('FixptModeInheritProd');
        OutputDataTypeSet=dsp.CommonSets.getSet('FixptModeAccumProd');
    end

    methods


        function obj=FIRRateConverter(varargin)
            coder.allowpcode('plain');
            obj@dsp.internal.AutoDesignMultirateFIR('mdspupfirdn2');
            obj.parseInputArguments(varargin{:});
            setEmptyAllowedStatus(obj,true);
        end

        function set.NumeratorSource(obj,val)
            clearMetaData(obj)
            obj.invalidateNumerator();

            obj.NumeratorSource=val;
        end

        function set.DesignMethod(obj,value)
            obj.DesignMethod=value;
            obj.invalidateNumerator();
        end

        function set.InterpolationFactor(obj,value)
            validateattributes(value,{'numeric'},{'positive','integer','scalar'},'','InterpolationFactor');
            clearMetaData(obj)
            obj.InterpolationFactor=value;
            obj.updateGCD();
            obj.invalidateNumerator();
        end

        function set.DecimationFactor(obj,value)
            validateattributes(value,{'numeric'},{'positive','integer','scalar'},'','DecimationFactor');
            clearMetaData(obj)
            obj.DecimationFactor=value;
            obj.updateGCD();
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

        function set.CoderTarget(obj,val)
            obj.CoderTarget=val;
        end

        function set.AllowArbitraryInputLength(obj,val)
            validateattributes(val,{'logical'},{'scalar'},'','AllowArbitraryInputLength');
            obj.AllowArbitraryInputLength=val;
        end

        function fdhdltool(obj,InputNumericType)























            if~exist('InputNumericType','var')
                error(message('hdlfilter:privgeneratehdl:fdhdltoolinputdatatypenotspecified'));
            end

            firrc=sysobjHdl(obj,'InputDataType',InputNumericType);
            fdhdltool(firrc,'InputDataType',InputNumericType);
        end

        function generatehdl(obj,varargin)

















            for k=1:length(varargin)
                if iscell(varargin{k})
                    [varargin{k}{:}]=convertStringsToChars(varargin{k}{:});
                else
                    varargin{k}=convertStringsToChars(varargin{k});
                end
            end

            firrc=sysobjHdl(obj,varargin{:});
            generatehdl(firrc,varargin{:},'FilterSystemObject',clone(obj));

        end
    end

    methods(Hidden,Access=public)
        function dtInfo=getFixedPointInfo(obj)
            dtInfo=getFixptDataTypeInfo(obj,...
            {'Coefficients','Product','Accumulator','Output'});
        end
    end

    methods(Hidden)
        function fd=getfdesign(obj)


            if obj.NumeratorSource=="Auto"&&obj.needNumeratorUpdate
                obj.designFIRFilter();
            end


            if isempty(obj.pFdesign)
                fd=obj.pFdesign;
            else

                if obj.InterpolationFactor==obj.DecimationFactor
                    fd=[];
                elseif strcmpi(obj.NumeratorSource,'property')&&obj.FactorsGCD>1



                    fdin=obj.pFdesign;
                    L=obj.EffectiveInterpolationFactor;
                    M=obj.EffectiveDecimationFactor;
                    fd=fdesign.rsrc(L,M,'Nyquist',max(L,M),...
                    'N,Ast',length(obj.EffectiveNumerator),fdin.Astop);
                else
                    fd=copy(obj.pFdesign);
                end
            end
        end

        function setParameters(obj)

            L=obj.EffectiveInterpolationFactor;
            M=obj.EffectiveDecimationFactor;
            h=obj.polyphaseMatrix();
            isCodegenForSim=double(coder.const(dsp.enhancedsim.IsSysObjSimInCodeGen(...
            obj.CoderTarget)));
            enableArbitrary=obj.AllowArbitraryInputLength;

            if isSizesOnlyCall(obj)
                obj.compSetParameters({...
                1,...
                h,...
                L,...
                M,...
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
                    1,...
                    h,...
                    L,...
                    M,...
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
                    1,...
                    h,...
                    L,...
                    M,...
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

        function y=supportsUnboundedIO(~)
            y=true;
        end

        function props=getNonFixedPointProperties(~)
            props=dsp.FIRRateConverter.getDisplayPropertiesList;
        end

        function props=getFixedPointProperties(~)
            props=dsp.FIRRateConverter.getDisplayFixedPointPropertiesList;
        end

        function flag=isPropertyActive(obj,prop)
            flag=~isInactivePropertyImpl(obj,prop);
        end

        function[L,M]=rateConversionFactors(obj,forceReduceGCD)



            if nargin<2
                forceReduceGCD=true;
            end








            if obj.NumeratorSource=="Property"


                L=obj.InterpolationFactor;
                M=obj.DecimationFactor;

                if forceReduceGCD
                    L=L/obj.FactorsGCD;
                    M=M/obj.FactorsGCD;
                end
            else

                L=obj.EffectiveInterpolationFactor;
                M=obj.EffectiveDecimationFactor;
            end
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
                setProperties(obj,nargin-2,varargin{1:end-1},'InterpolationFactor','DecimationFactor','Numerator');
                return
            end

            nargs=nargin-1;


            numeratorSpecifiedPV=any(cellfun(@(x)(isstring(x)||ischar(x))&&x=="Numerator",varargin));


            if isprop(obj,varargin{1})
                setProperties(obj,nargs,varargin{:});



                if strcmpi(obj.NumeratorSource,'Property')&&~numeratorSpecifiedPV
                    obj.designFIRFilter();
                end
                return;
            end


            if nargs<=2
                setProperties(obj,nargs,varargin{:},'InterpolationFactor','DecimationFactor');


                obj.designFIRFilter();
                return;
            end





            if isnumeric(varargin{1})&&isnumeric(varargin{2})&&isnumeric(varargin{3})
                setProperties(obj,nargs,varargin{:},'InterpolationFactor','DecimationFactor','Numerator');
                return;
            end



            if isnumeric(varargin{1})&&~isnumeric(varargin{2})
                setProperties(obj,nargs,varargin{:},'InterpolationFactor');
                if~numeratorSpecifiedPV
                    obj.designFIRFilter();
                end
                return;
            end







            if any(strcmpi({'auto','zoh','linear','kaiser'},varargin{3}))

                if lower(varargin{3})=="auto"

                    args={varargin{1:2},'NumeratorSource',varargin{3:end}};
                else




                    args={varargin{1:2},'NumeratorSource','Auto','DesignMethod',varargin{3:end}};
                end

                setProperties(obj,length(args),args{:},'InterpolationFactor','DecimationFactor');
                return;
            end



            if~isprop(obj,varargin{3})

                coder.internal.error('dsp:system:AutoDesignMultirateFIR:invalidNumeratorArgument');
            end

            setProperties(obj,nargs,varargin{:},'InterpolationFactor','DecimationFactor');


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

        function s=infoImpl(obj,varargin)
            L=obj.InterpolationFactor;
            M=obj.DecimationFactor;
            num=obj.Numerator;

            Leff=obj.EffectiveInterpolationFactor;
            Meff=obj.EffectiveDecimationFactor;
            numeff=obj.EffectiveNumerator;


            dflt=parseArithmetic(obj,varargin);

            structurestr='Direct-Form FIR Polyphase Sample-Rate Converter';


            stablestr=getString(message('dsp:system:info:Yes'));


            if islinphase(numeff)
                linphasestr=getString(message('dsp:system:info:Yes'));
                if isreal(numeff)
                    t=firtype(numeff);
                    if iscell(t)
                        t=[t{:}];
                    end
                    linphasestr=[linphasestr,' (Type ',int2str(t),')'];
                end
            else
                linphasestr=getString(message('dsp:system:info:No'));
            end


            S={};
            S={S{:},{getString(message('dsp:system:info:FilterStructure')),structurestr}};

            K=obj.FactorsGCD;


            if K>1
                S={S{:},{getString(message('dsp:system:info:FactorsGCD')),sprintf('%d',K)}};
                S={S{:},{getString(message('dsp:system:info:InterpolationFactor')),sprintf('%d (effective rate %d)',L,Leff)}};
                S={S{:},{getString(message('dsp:system:info:DecimationFactor')),sprintf('%d (effective rate %d)',M,Meff)}};
            else
                S={S{:},{getString(message('dsp:system:info:InterpolationFactor')),sprintf('%d',L)}};
                S={S{:},{getString(message('dsp:system:info:DecimationFactor')),sprintf('%d',M)}};
            end

            if obj.NumeratorSource=="Auto"
                S={S{:},{getString(message('dsp:system:info:DesignMethod')),obj.DesignMethod}};
                coff=max(Leff,Meff);
                if obj.DesignMethod=="Kaiser"
                    S={S{:},{getString(message('dsp:system:info:NominalCutoff')),sprintf('1/%d',coff)}};
                end
            end


            if K>1&&obj.NumeratorSource=="Property"
                S={S{:},{getString(message('dsp:system:info:FilterLength')),sprintf('%d (effective length %d)',length(num),length(numeff))}};
            else
                S={S{:},{getString(message('dsp:system:info:FilterLength')),sprintf('%d',length(num))}};
            end

            S={S{:},{getString(message('dsp:system:info:PolyphaseLength')),int2str(size(obj.polyphaseMatrix,2))}};
            S={S{:},{getString(message('dsp:system:info:Stable')),stablestr}};
            S={S{:},{getString(message('dsp:system:info:LinearPhase')),linphasestr}};


            S={S{:},{' ',' '}};
            S={S{:},{getString(message('dsp:system:info:Arithmetic')),dflt.Arithmetic}};

            [fqn,fqv]=info(dflt.filterquantizer);

            if~isempty(fqv)
                S={S{:},{fqn{1},fqv{1}}};
            end

            if isreal(numeff)
                cpxstr='real';
            else
                cpxstr='complex';
            end


            infostrs=sprintf('Discrete-Time FIR Multirate Filter (%s)',cpxstr);


            S=[S{:}];

            fname=S(1:2:end);
            fval=S(2:2:end);

            infostrs={...
            infostrs,...
            repmat('-',1,size(infostrs,2)),...
            [char(fname{:}),repmat('  : ',length(fname),1),char(fval{:})],...
            };


            spacerindx=strcmp(fname,' ');
            infostrs{end}(spacerindx,:)=' ';


            long_str='';
            if nargin>1&&any(strcmpi(varargin,'long'))

                fdes=obj.getfdesign();


                if isfdtbxinstalled||~isempty(fdes)

                    desmeth=obj.pDesignMethod;
                    fmeth=obj.pFmethod;
                    if~isempty(desmeth)&&~isempty(fmeth)&&isprop(fmeth,'FromFilterDesigner')&&fmeth.FromFilterDesigner


                        fdesigner=obj.getfdesign;
                        desmeth=fdesigner.DesignMethod;
                    elseif~isempty(desmeth)&&~isempty(fmeth)&&~isempty(fdes)

                        desmeth=signal.internal.DesignfiltProcessCheck.convertdesignmethodnames(desmeth,true,'fdesignToDesignfilt','long');
                    end

                    if~isempty(desmeth)
                        desmethstr=[getString(message('signal:dfilt:info:DesignAlgorithm')),' : ',desmeth];
                        long_str=char({long_str,' ',...
                        getString(message('signal:dfilt:info:DesignMethodInformation')),...
                        desmethstr});
                    end


                    if obj.FactorsGCD>1
                        effstr='Effective ';
                    else
                        effstr='';
                    end


                    fdes=obj.getfdesign;
                    if~isempty(fdes)
                        long_str=char({long_str,' ',...
                        [effstr,getString(message('signal:dfilt:info:DesignSpecifications'))],...
                        fdes.tostring});
                    end

                    m=measure(dflt);
                    if~isempty(m)
                        long_str=char({long_str,' ',...
                        [effstr,getString(message('signal:dfilt:info:Measurements'))],...
                        m.tostring});
                    end


                    try %#ok
                        c=cost(dflt);
                        long_str=char({long_str,' ',...
                        [effstr,getString(message('signal:dfilt:info:ImplementationCost'))],...
                        c.tostrinet});
                    catch %#ok<CTCH>

                    end

                end
            end


            infostrs={infostrs{:},long_str};

            s=char(infostrs{:});
        end



        function s=saveObjectImpl(obj)
            s=saveObjectImpl@dsp.internal.AutoDesignMultirateFIR(obj);
        end


        function loadObjectImpl(obj,s,wasLocked)
            loadObjectImpl@dsp.internal.AutoDesignMultirateFIR(obj,s,wasLocked);
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
                if~matlab.system.isSpecifiedTypeMode(obj.CoefficientsDataType)
                    flag=true;
                end
            otherwise
                flag=isInactivePropertyImpl@dsp.internal.AutoDesignMultirateFIR(obj,prop);
            end
        end

        function d=convertToDFILT(obj,arith)

            w=warning('off','dsp:mfilt:mfilt:Obsolete');
            restoreWarn=onCleanup(@()warning(w));

            d=mfilt.firsrc;%#ok

            d.RateChangeFactors=[obj.EffectiveInterpolationFactor,...
            obj.EffectiveDecimationFactor];

            d.Numerator=obj.EffectiveNumerator;

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
                    d.FilterInternals='SpecifyPrecision';
                    fixedpointinfo=getCompiledFixedPointInfo(obj);

                    d.AccumWordLength=fixedpointinfo.AccumulatorDataType.WordLength;
                    d.AccumFracLength=fixedpointinfo.AccumulatorDataType.FractionLength;

                    d.ProductWordLength=fixedpointinfo.ProductDataType.WordLength;
                    d.ProductFracLength=fixedpointinfo.ProductDataType.FractionLength;

                    d.OutputWordLength=fixedpointinfo.OutputDataType.WordLength;
                    d.OutputFracLength=fixedpointinfo.OutputDataType.FractionLength;
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

        function H=polyphaseMatrix(obj)

            L=obj.EffectiveInterpolationFactor;
            h=double(obj.EffectiveNumerator);
            len=length(h);
            if(rem(len,L)~=0)
                nzeros=L-rem(len,L);
                h=[h(:);zeros(nzeros,1)];
            end

            H=(reshape(h,L,length(h)/L)).';
        end

        function setPortDataTypeConnections(obj)
            setPortDataTypeConnection(obj,1,1);
        end

        function updateGCD(obj)
            obj.FactorsGCD=gcd(double(obj.InterpolationFactor),...
            double(obj.DecimationFactor));
        end

    end

    methods(Static)
        function helpFixedPoint






            matlab.system.dispFixptHelp('dsp.FIRRateConverter',dsp.FIRRateConverter.getDisplayFixedPointPropertiesList);
        end
    end
    methods(Static,Access=protected)
        function groups=getPropertyGroupsImpl

            propertyListMain=dsp.FIRRateConverter.getDisplayPropertiesList;
            propertyListDataType=dsp.FIRRateConverter.getDisplayFixedPointPropertiesList;
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
            a='dspmlti4/FIR Rate Conversion';
        end

        function props=getDisplayPropertiesList()
            props={...
            'InterpolationFactor',...
            'DecimationFactor',...
'NumeratorSource'...
            ,'DesignMethod',...
            'Numerator'};
        end

        function props=getDisplayFixedPointPropertiesList()
            props={'FullPrecisionOverride',...
            'RoundingMethod','OverflowAction',...
            'CoefficientsDataType','CustomCoefficientsDataType',...
            'ProductDataType','CustomProductDataType',...
            'AccumulatorDataType','CustomAccumulatorDataType',...
            'OutputDataType','CustomOutputDataType'};
        end



        function props=getValueOnlyProperties()
            props={'InterpolationFactor','DecimationFactor','Numerator'};
        end

        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end

end

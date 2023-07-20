classdef BiquadFilter<matlab.system.SFunSystem&dsp.internal.FilterAnalysis























































































































%#function mdspbiquad

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)




        Structure='Direct form II transposed';



        SOSMatrixSource='Property';















        SOSMatrix=[1,0.3,0.4,1,0.1,0.2];










        ScaleValues=1;
























        InitialConditions=0;



























        NumeratorInitialConditions=0;



























        DenominatorInitialConditions=0;







        RoundingMethod='Floor';



        OverflowAction='Wrap';






        MultiplicandDataType='Same as output';







        CustomMultiplicandDataType=numerictype([],32,30);




        SectionInputDataType='Same as input';







        CustomSectionInputDataType=numerictype([],16,15);





        SectionOutputDataType='Same as section input';







        CustomSectionOutputDataType=numerictype([],16,15);








        NumeratorCoefficientsDataType='Same word length as input';












        CustomNumeratorCoefficientsDataType=numerictype([],16,15);







        OptimizeUnityScaleValues(1,1)logical=true;






        ScaleValuesInputPort(1,1)logical=true;
    end
    properties(Dependent,Nontunable)








        DenominatorCoefficientsDataType;
    end
    properties(Nontunable)












        CustomDenominatorCoefficientsDataType=numerictype([],16,15);
    end
    properties(Dependent,Nontunable)








        ScaleValuesDataType;
    end
    properties(Nontunable)











        CustomScaleValuesDataType=numerictype([],16,15);






        NumeratorProductDataType='Same as input';










        CustomNumeratorProductDataType=numerictype([],32,30);
    end
    properties(Dependent,Nontunable)






        DenominatorProductDataType;
    end
    properties(Nontunable)










        CustomDenominatorProductDataType=numerictype([],32,30);






        NumeratorAccumulatorDataType='Same as product';










        CustomNumeratorAccumulatorDataType=numerictype([],32,30);
    end
    properties(Dependent,Nontunable)






        DenominatorAccumulatorDataType;
    end
    properties(Nontunable)










        CustomDenominatorAccumulatorDataType=numerictype([],32,30);
    end
    properties(Dependent,Nontunable)





        StateDataType;







        CustomStateDataType;
    end
    properties(Nontunable)







        NumeratorStateDataType='Same as accumulator';









        CustomNumeratorStateDataType=numerictype([],16,15);
    end
    properties(Dependent,Nontunable)







        DenominatorStateDataType;
    end
    properties(Nontunable)










        CustomDenominatorStateDataType=numerictype([],16,15);




        OutputDataType='Same as accumulator';







        CustomOutputDataType=numerictype([],16,15);
    end

    properties(Constant,Hidden)

        StructureSet=matlab.system.StringSet({'Direct form I',...
        'Direct form I transposed','Direct form II',...
        'Direct form II transposed'});
        SOSMatrixSourceSet=dsp.CommonSets.getSet('PropertyOrInputPort');

        RoundingMethodSet=dsp.CommonSets.getSet('RoundingMethod');
        OverflowActionSet=dsp.CommonSets.getSet('OverflowAction');
        MultiplicandDataTypeSet=matlab.system.StringSet({'Same as output',matlab.system.getSpecifyString('scaled')});
        SectionInputDataTypeSet=dsp.CommonSets.getSet('FixptModeBasic');
        SectionOutputDataTypeSet=matlab.system.StringSet({'Same as section input',matlab.system.getSpecifyString('scaled')});
        NumeratorCoefficientsDataTypeSet=dsp.CommonSets.getSet('FixptModeEitherScale');
        DenominatorCoefficientsDataTypeSet=dsp.CommonSets.getSet('FixptModeEitherScale');
        ScaleValuesDataTypeSet=dsp.CommonSets.getSet('FixptModeEitherScale');
        NumeratorProductDataTypeSet=dsp.CommonSets.getSet('FixptModeInherit');
        DenominatorProductDataTypeSet=dsp.CommonSets.getSet('FixptModeInherit');
        NumeratorAccumulatorDataTypeSet=dsp.CommonSets.getSet('FixptModeProd');
        DenominatorAccumulatorDataTypeSet=dsp.CommonSets.getSet('FixptModeProd');
        StateDataTypeSet=dsp.CommonSets.getSet('FixptModeAccum');
        NumeratorStateDataTypeSet=dsp.CommonSets.getSet('FixptModeAccum');
        DenominatorStateDataTypeSet=dsp.CommonSets.getSet('FixptModeAccum');
        OutputDataTypeSet=dsp.CommonSets.getSet('FixptModeAccum');
    end

    methods
        function obj=BiquadFilter(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mdspbiquad');
            setProperties(obj,nargin,varargin{:},'SOSMatrix','ScaleValues');
            setFrameStatus(obj,true);
            setEmptyAllowedStatus(obj,true);
        end

        function fdhdltool(obj,InputNumericType)
























            if~exist('InputNumericType','var')
                error(message('hdlfilter:privgeneratehdl:fdhdltoolinputdatatypenotspecified'));
            end

            errIfNotValidCoeffSource(obj);
            errIfNonZeroInitialConditions(obj);
            biquad_dfilt=sysobjHdl(obj,'InputDataType',InputNumericType);
            fdhdltool(biquad_dfilt,'InputDataType',InputNumericType);


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
            errIfNonZeroInitialConditions(obj);

            [~,biquad_so]=sysobjHdl(obj,varargin{:});

            inname=inputname(1);
            if~any(strcmpi({varargin{1:2:end}},'name'))&&~isempty(inname)%#ok
                varargin(end+1)={'Name'};
                varargin{end+1}=inname;
            end
            privgeneratehdl(biquad_so,...
            varargin{:},'FilterSystemObject',biquad_so);

...
...
...
...
...
        end

        function set.Structure(obj,val)
            clearMetaData(obj)
            obj.Structure=val;
        end

        function set.SOSMatrixSource(obj,val)
            clearMetaData(obj)
            obj.SOSMatrixSource=val;
        end

        function set.SOSMatrix(obj,val)

            coder.internal.errorIf(~isnumeric(val)||~ismatrix(val)||...
            size(val,2)~=6,...
            'dsp:system:sosMatNotMx6');
            clearMetaData(obj)
            obj.SOSMatrix=val;
        end

        function set.ScaleValues(obj,val)
            clearMetaData(obj)
            obj.ScaleValues=val;
        end

        function set.CustomMultiplicandDataType(obj,val)
            validateCustomDataType(obj,'CustomMultiplicandDataType',val,...
            getFixedPointRestrictions(obj,'CustomMultiplicandDataType'));
            obj.CustomMultiplicandDataType=val;
        end
        function set.CustomSectionInputDataType(obj,val)
            validateCustomDataType(obj,'CustomSectionInputDataType',val,...
            getFixedPointRestrictions(obj,'CustomSectionInputDataType'));
            obj.CustomSectionInputDataType=val;
        end
        function set.CustomSectionOutputDataType(obj,val)
            validateCustomDataType(obj,'CustomSectionOutputDataType',val,...
            getFixedPointRestrictions(obj,'CustomSectionOutputDataType'));
            obj.CustomSectionOutputDataType=val;
        end
        function set.CustomNumeratorProductDataType(obj,val)
            validateCustomDataType(obj,'CustomNumeratorProductDataType',val,...
            getFixedPointRestrictions(obj,'CustomNumeratorProductDataType'));
            obj.CustomNumeratorProductDataType=val;
        end
        function set.CustomDenominatorProductDataType(obj,val)
            validateCustomDataType(obj,'CustomDenominatorProductDataType',val,...
            getFixedPointRestrictions(obj,'CustomDenominatorProductDataType'));
            obj.CustomDenominatorProductDataType=val;
        end
        function set.CustomNumeratorAccumulatorDataType(obj,val)
            validateCustomDataType(obj,'CustomNumeratorAccumulatorDataType',val,...
            getFixedPointRestrictions(obj,'CustomNumeratorAccumulatorDataType'));
            obj.CustomNumeratorAccumulatorDataType=val;
        end
        function set.CustomDenominatorAccumulatorDataType(obj,val)
            validateCustomDataType(obj,'CustomDenominatorAccumulatorDataType',val,...
            getFixedPointRestrictions(obj,'CustomDenominatorAccumulatorDataType'));
            obj.CustomDenominatorAccumulatorDataType=val;
        end

        function set.CustomNumeratorStateDataType(obj,val)
            validateCustomDataType(obj,'CustomNumeratorStateDataType',val,...
            getFixedPointRestrictions(obj,'CustomNumeratorStateDataType'));
            obj.CustomNumeratorStateDataType=val;
        end
        function set.CustomDenominatorStateDataType(obj,val)
            validateCustomDataType(obj,'CustomDenominatorStateDataType',val,...
            getFixedPointRestrictions(obj,'CustomDenominatorStateDataType'));
            obj.CustomDenominatorStateDataType=val;
        end
        function set.CustomOutputDataType(obj,val)
            validateCustomDataType(obj,'CustomOutputDataType',val,...
            getFixedPointRestrictions(obj,'CustomOutputDataType'));
            obj.CustomOutputDataType=val;
        end
        function set.CustomScaleValuesDataType(obj,val)
            validateCustomDataType(obj,'CustomScaleValuesDataType',val,...
            getFixedPointRestrictions(obj,'CustomScaleValuesDataType'));
            obj.CustomScaleValuesDataType=val;
        end
        function set.CustomDenominatorCoefficientsDataType(obj,val)
            validateCustomDataType(obj,'CustomDenominatorCoefficientsDataType',...
            val,getFixedPointRestrictions(obj,...
            'CustomDenominatorCoefficientsDataType'));
            obj.CustomDenominatorCoefficientsDataType=val;
        end
        function set.CustomNumeratorCoefficientsDataType(obj,val)
            validateCustomDataType(obj,'CustomNumeratorCoefficientsDataType',...
            val,getFixedPointRestrictions(obj,...
            'CustomNumeratorCoefficientsDataType'));
            obj.CustomNumeratorCoefficientsDataType=val;
        end



        function set.StateDataType(obj,value)
            obj.NumeratorStateDataType=value;
        end
        function value=get.StateDataType(obj)
            value=obj.NumeratorStateDataType;
        end
        function set.CustomStateDataType(obj,value)
            obj.CustomNumeratorStateDataType=value;
        end
        function value=get.CustomStateDataType(obj)
            value=obj.CustomNumeratorStateDataType;
        end

        function set.DenominatorCoefficientsDataType(obj,value)
            obj.NumeratorCoefficientsDataType=value;
        end
        function value=get.DenominatorCoefficientsDataType(obj)
            value=obj.NumeratorCoefficientsDataType;
        end
        function set.ScaleValuesDataType(obj,value)
            obj.NumeratorCoefficientsDataType=value;
        end
        function value=get.ScaleValuesDataType(obj)
            value=obj.NumeratorCoefficientsDataType;
        end

        function set.DenominatorProductDataType(obj,value)
            obj.NumeratorProductDataType=value;
        end
        function value=get.DenominatorProductDataType(obj)
            value=obj.NumeratorProductDataType;
        end

        function set.DenominatorAccumulatorDataType(obj,value)
            obj.NumeratorAccumulatorDataType=value;
        end
        function value=get.DenominatorAccumulatorDataType(obj)
            value=obj.NumeratorAccumulatorDataType;
        end

        function set.DenominatorStateDataType(obj,value)
            obj.NumeratorStateDataType=value;
        end
        function value=get.DenominatorStateDataType(obj)
            value=obj.NumeratorStateDataType;
        end




        function Hnew=scale(obj,varargin)








































































            [d,varargin]=parseArithmetic(obj,varargin);
            if strcmpi(d.Arithmetic,'fixed')
                d.OverflowMode=obj.OverflowAction;
            end
            scale(d,varargin{:});


            d=reffilter(d);

            if nargout==0
                if isLocked(obj)
                    release(obj)
                    msg=getString(message('dsp:dsp:private:FilterSystemObjectBase:Coefficients'));
                    coder.internal.warning('dsp:dsp:private:FilterSystemObjectBase:Release',msg);
                end
                obj.SOSMatrix=d.sosMatrix;
                obj.ScaleValues=d.ScaleValues;

                setsysobjmetadata(d,obj);
            else
                Hnew=clone(obj);
                release(Hnew);
                Hnew.SOSMatrix=d.sosMatrix;
                Hnew.ScaleValues=d.ScaleValues;

                setsysobjmetadata(d,Hnew);
            end
        end

        function OPTS=scaleopts(obj,varargin)














            [d,varargin]=parseArithmetic(obj,varargin);
            if strcmpi(d.Arithmetic,'fixed')
                d.OverflowMode=obj.OverflowAction;
            end
            OPTS=scaleopts(d,varargin{:});
        end

        function s=scalecheck(obj,varargin)




































            [d,varargin]=parseArithmetic(obj,varargin);
            if strcmpi(d.Arithmetic,'fixed')
                d.OverflowMode=obj.OverflowAction;
            end
            s=scalecheck(d,varargin{:});
        end

        function Hnew=reorder(obj,varargin)

























































            [d,varargin]=parseArithmetic(obj,varargin);
            if strcmpi(d.Arithmetic,'fixed')
                d.OverflowMode=obj.OverflowAction;
            end
            reorder(d,varargin{:});


            d=reffilter(d);

            if nargout==0
                if isLocked(obj)
                    release(obj)
                    msg=getString(message('dsp:dsp:private:FilterSystemObjectBase:Coefficients'));
                    coder.internal.warning('dsp:dsp:private:FilterSystemObjectBase:Release',msg);
                end
                obj.SOSMatrix=d.sosMatrix;
                obj.ScaleValues=d.ScaleValues;

                setsysobjmetadata(d,obj);
            else
                Hnew=clone(obj);
                release(Hnew);
                Hnew.SOSMatrix=d.sosMatrix;
                Hnew.ScaleValues=d.ScaleValues;

                setsysobjmetadata(d,Hnew);
            end
        end

        function filterCell=cumsec(obj,varargin)


























            [d,varargin]=parseArithmetic(obj,varargin);
            if strcmpi(d.Arithmetic,'fixed')
                d.OverflowMode=obj.OverflowAction;
            end

            if nargout>0
                H=cumsec(d,varargin{:});
                filterCell=cell(1,length(H));
                for idx=1:length(H)


                    filterCell{idx}=clone(obj);
                    release(filterCell{idx});


                    if strcmp({'Direct form I transposed','Direct form I'},obj.Structure)
                        filterCell{idx}.NumeratorInitialConditions=0;
                        filterCell{idx}.DenominatorInitialConditions=0;
                    else
                        filterCell{idx}.InitialConditions=0;
                    end
                    filterCell{idx}.SOSMatrix=H(idx).sosMatrix;
                    filterCell{idx}.ScaleValues=H(idx).ScaleValues;
                end
            else
                cumsec(d,varargin{:});
            end
        end
    end

    methods(Access=public,Hidden)
        function dtInfo=getFixedPointInfo(obj)

            dtInfo=getFixptDataTypeInfo(obj,...
            {'Multiplicand','SectionInput','SectionOutput',...
            'NumeratorCoefficients','DenominatorCoefficients','ScaleValues',...
            'NumeratorProduct','DenominatorProduct','NumeratorAccumulator',...
            'DenominatorAccumulator','NumeratorState','DenominatorState','Output'});


            if strcmp(obj.SectionInputDataType,'Same as input')
                dtInfo.SectionInputDataType=1;
            elseif strcmp(obj.SectionInputDataType,matlab.system.getSpecifyString('scaled'))
                dtInfo.SectionInputDataType=2;
            end
            if strcmp(obj.SectionOutputDataType,'Same as section input')
                dtInfo.SectionOutputDataType=1;
            elseif strcmp(obj.SectionOutputDataType,matlab.system.getSpecifyString('scaled'))
                dtInfo.SectionOutputDataType=2;
            end
            if strcmp(obj.MultiplicandDataType,'Same as output')
                dtInfo.MultiplicandDataType=1;
            elseif strcmp(obj.MultiplicandDataType,matlab.system.getSpecifyString('scaled'))
                dtInfo.MultiplicandDataType=2;
            end

        end
    end

    methods(Hidden)
        function setParameters(obj)

            FilterStructureIdx=getIndex(obj.StructureSet,...
            obj.Structure)-1;
            CoeffSourceIdx=getIndex(obj.SOSMatrixSourceSet,...
            obj.SOSMatrixSource);
            ScaleValuesOptionIdx=2-obj.ScaleValuesInputPort;

            [numSections,numCoefficients]=size(obj.SOSMatrix);

            if~isempty(obj.SOSMatrix)&&(numSections>0)&&(numCoefficients==6)

                coder.internal.errorIf(any(obj.SOSMatrix(:,4)==0),...
                'dsp:system:BiquadFilter:a0EqualZeroError');

                processedSOSMatrix=obj.SOSMatrix;
            end


            InputProcessing=1;


            if~strcmp(obj.SOSMatrixSource,'Input port')
                scaleValuesOrOne=obj.ScaleValues;
            else
                if numSections>1
                    scaleValuesOrOne=ones(1,(numSections+1));
                else
                    scaleValuesOrOne=ones(1,2);
                end
            end

            if isSizesOnlyCall(obj)
                obj.compSetParameters({...
                CoeffSourceIdx,...
                FilterStructureIdx,...
                processedSOSMatrix,...
                scaleValuesOrOne,...
                double(obj.OptimizeUnityScaleValues),...
                ScaleValuesOptionIdx,...
                obj.InitialConditions,...
                obj.NumeratorInitialConditions,...
                obj.DenominatorInitialConditions,...
                InputProcessing,...
                0,...
                16,...
                15,...
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
                2,...
                2,...
                2,...
                2,...
1...
                });
            else

                dtInfo=getFixedPointInfo(obj);


                coder.internal.errorIf(dtInfo.NumeratorCoefficientsWordLength~=dtInfo.DenominatorCoefficientsWordLength||...
                dtInfo.NumeratorCoefficientsWordLength~=dtInfo.ScaleValuesWordLength,...
                'dsp:system:BiquadFilter:mismatchedWordLengths');

                coder.internal.errorIf(dtInfo.NumeratorProductWordLength~=dtInfo.DenominatorProductWordLength,...
                'dsp:system:BiquadFilter:mismatchedWordLengths1');

                coder.internal.errorIf(dtInfo.NumeratorAccumulatorWordLength~=dtInfo.DenominatorAccumulatorWordLength,...
                'dsp:system:BiquadFilter:mismatchedWordLengths2');


                if(FilterStructureIdx==0)||(FilterStructureIdx==1)
                    coder.internal.errorIf(dtInfo.NumeratorStateWordLength~=dtInfo.DenominatorStateWordLength,...
                    'dsp:system:BiquadFilter:mismatchedwordlengths3');
                end

                obj.compSetParameters({...
                CoeffSourceIdx,...
                FilterStructureIdx,...
                processedSOSMatrix,...
                scaleValuesOrOne,...
                double(obj.OptimizeUnityScaleValues),...
                ScaleValuesOptionIdx,...
                obj.InitialConditions,...
                obj.NumeratorInitialConditions,...
                obj.DenominatorInitialConditions,...
                InputProcessing,...
                0,...
                16,...
                15,...
                dtInfo.DenominatorCoefficientsFracLength,...
                dtInfo.ScaleValuesFracLength,...
                dtInfo.SectionInputDataType,...
                dtInfo.SectionOutputDataType,...
                dtInfo.SectionInputWordLength,...
                dtInfo.SectionInputFracLength,...
                dtInfo.SectionOutputWordLength,...
                dtInfo.SectionOutputFracLength,...
                dtInfo.MultiplicandDataType,...
                dtInfo.MultiplicandWordLength,...
                dtInfo.MultiplicandFracLength,...
                dtInfo.DenominatorProductFracLength,...
                dtInfo.DenominatorAccumulatorFracLength,...
                dtInfo.DenominatorStateFracLength,...
                dtInfo.NumeratorCoefficientsDataType,...
                dtInfo.NumeratorCoefficientsWordLength,...
                dtInfo.NumeratorCoefficientsFracLength,...
                dtInfo.NumeratorProductDataType,...
                dtInfo.NumeratorProductWordLength,...
                dtInfo.NumeratorProductFracLength,...
                dtInfo.NumeratorAccumulatorDataType,...
                dtInfo.NumeratorAccumulatorWordLength,...
                dtInfo.NumeratorAccumulatorFracLength,...
                dtInfo.NumeratorStateDataType,...
                dtInfo.NumeratorStateWordLength,...
                dtInfo.NumeratorStateFracLength,...
                dtInfo.OutputDataType,...
                dtInfo.OutputWordLength,...
                dtInfo.OutputFracLength,...
                dtInfo.RoundingMethod,...
                dtInfo.OverflowAction...
                });
            end
        end
        function restrictionsCell=getFixedPointRestrictions(obj,prop)
            restrictionsCell={};
            switch prop
            case{'CustomMultiplicandDataType','CustomSectionInputDataType',...
                'CustomSectionOutputDataType','CustomNumeratorProductDataType',...
                'CustomDenominatorProductDataType',...
                'CustomNumeratorAccumulatorDataType',...
                'CustomDenominatorAccumulatorDataType',...
                'CustomNumeratorStateDataType','CustomDenominatorStateDataType',...
                'CustomStateDataType',...
                'CustomOutputDataType'}
                restrictionsCell={'AUTOSIGNED','SCALED'};
            case{'CustomScaleValuesDataType',...
                'CustomDenominatorCoefficientsDataType',...
                'CustomNumeratorCoefficientsDataType'}
                restrictionsCell={'AUTOSIGNED'};
            otherwise
                coder.internal.errorIf(true,...
                'dsp:dsp:private:FilterSystemObjectBase:InvalidProperty',prop,class(obj));
            end
        end
        function props=getNonFixedPointProperties(~)
            props=dsp.BiquadFilter.getDisplayPropertiesImpl;
        end
        function props=getFixedPointProperties(~)
            props=dsp.BiquadFilter.getDisplayFixedPointPropertiesImpl;
        end
        function flag=isPropertyActive(obj,prop)
            flag=~isInactivePropertyImpl(obj,prop);
        end

        function y=supportsUnboundedIO(~)
            y=true;
        end
    end

    methods(Access=protected)
        function validateInputsImpl(obj,varargin)

            if~isempty(varargin)
                inputData=varargin{1};
                cacheInputDataType(obj,inputData)
            end
        end
        function y=infoImpl(obj,varargin)
            y=infoFA(obj,varargin{:});
        end
        function flag=isInactivePropertyImpl(obj,prop)
            flag=false;
            switch prop
            case{'SOSMatrix','ScaleValues','OptimizeUnityScaleValues',...
                'NumeratorCoefficientsDataType','DenominatorCoefficientsDataType',...
                'ScaleValuesDataType'}
                if strcmp(obj.SOSMatrixSource,'Input port')
                    flag=true;
                end
            case 'CustomNumeratorCoefficientsDataType'
                if strcmp(obj.SOSMatrixSource,'Input port')||...
                    ~matlab.system.isSpecifiedTypeMode(obj.NumeratorCoefficientsDataType)
                    flag=true;
                end
            case 'CustomDenominatorCoefficientsDataType'
                if strcmp(obj.SOSMatrixSource,'Input port')||...
                    ~matlab.system.isSpecifiedTypeMode(obj.DenominatorCoefficientsDataType)
                    flag=true;
                end
            case 'CustomScaleValuesDataType'
                if strcmp(obj.SOSMatrixSource,'Input port')||...
                    ~matlab.system.isSpecifiedTypeMode(obj.ScaleValuesDataType)
                    flag=true;
                end
            case 'ScaleValuesInputPort'
                if~strcmp(obj.SOSMatrixSource,'Input port')
                    flag=true;
                end
            case{'InitialConditions','StateDataType'}
                if strcmp(obj.Structure,'Direct form I')||...
                    strcmp(obj.Structure,'Direct form I transposed')
                    flag=true;
                end
            case{'MultiplicandDataType','NumeratorStateDataType',...
                'DenominatorStateDataType'}
                if strcmp(obj.Structure,'Direct form I')||...
                    strcmp(obj.Structure,'Direct form II')||...
                    strcmp(obj.Structure,'Direct form II transposed')
                    flag=true;
                end
            case 'CustomMultiplicandDataType'
                if strcmp(obj.Structure,'Direct form I')||...
                    strcmp(obj.Structure,'Direct form II')||...
                    strcmp(obj.Structure,'Direct form II transposed')||...
                    ~matlab.system.isSpecifiedTypeMode(obj.MultiplicandDataType)
                    flag=true;
                end
            case 'CustomStateDataType'
                if strcmp(obj.Structure,'Direct form I')||...
                    strcmp(obj.Structure,'Direct form I transposed')||...
                    ~matlab.system.isSpecifiedTypeMode(obj.StateDataType)
                    flag=true;
                end
            case 'CustomNumeratorStateDataType'
                if strcmp(obj.Structure,'Direct form I')||...
                    strcmp(obj.Structure,'Direct form II')||...
                    strcmp(obj.Structure,'Direct form II transposed')||...
                    ~matlab.system.isSpecifiedTypeMode(obj.NumeratorStateDataType)
                    flag=true;
                end
            case 'CustomDenominatorStateDataType'
                if strcmp(obj.Structure,'Direct form I')||...
                    strcmp(obj.Structure,'Direct form II')||...
                    strcmp(obj.Structure,'Direct form II transposed')||...
                    ~matlab.system.isSpecifiedTypeMode(obj.DenominatorStateDataType)
                    flag=true;
                end
            case{'NumeratorInitialConditions','DenominatorInitialConditions'}
                if strcmp(obj.Structure,'Direct form II')||...
                    strcmp(obj.Structure,'Direct form II transposed')
                    flag=true;
                end
            case{'SectionInputDataType','SectionOutputDataType'}
                if(strcmpi(obj.Structure,'Direct form I transposed')||...
                    strcmpi(obj.Structure,'Direct form II'))&&...
                    strcmp(obj.SOSMatrixSource,'Input port')&&...
                    ~obj.ScaleValuesInputPort
                    flag=true;
                end
            case 'CustomSectionInputDataType'
                if~matlab.system.isSpecifiedTypeMode(obj.SectionInputDataType)
                    flag=true;
                end
            case 'CustomSectionOutputDataType'
                if~matlab.system.isSpecifiedTypeMode(obj.SectionOutputDataType)
                    flag=true;
                end
            case 'CustomNumeratorProductDataType'
                if~matlab.system.isSpecifiedTypeMode(obj.NumeratorProductDataType)
                    flag=true;
                end
            case 'CustomDenominatorProductDataType'
                if~matlab.system.isSpecifiedTypeMode(obj.DenominatorProductDataType)
                    flag=true;
                end
            case 'CustomNumeratorAccumulatorDataType'
                if~matlab.system.isSpecifiedTypeMode(obj.NumeratorAccumulatorDataType)
                    flag=true;
                end
            case 'CustomDenominatorAccumulatorDataType'
                if~matlab.system.isSpecifiedTypeMode(obj.DenominatorAccumulatorDataType)
                    flag=true;
                end
            case 'CustomOutputDataType'
                if~matlab.system.isSpecifiedTypeMode(obj.OutputDataType)
                    flag=true;
                end
            end
        end

        function d=convertToDFILT(obj,arith)



            if~strcmp(obj.SOSMatrixSource,'Property')
                sendNoAvailableCoefficientsError(obj,'SOSMatrixSource');
            end

            switch obj.Structure
            case 'Direct form I'
                d=dfilt.df1sos;
            case 'Direct form I transposed'
                d=dfilt.df1tsos;
            case 'Direct form II'
                d=dfilt.df2sos;
            case 'Direct form II transposed'
                d=dfilt.df2tsos;
            end

            d.sosMatrix=obj.SOSMatrix;
            d.ScaleValues=obj.ScaleValues;
            d.OptimizeScaleValues=obj.OptimizeUnityScaleValues;
            d.Arithmetic=arith;
            d.PersistentMemory=true;

            if strcmpi(arith,'fixed')
                if strcmpi(obj.NumeratorCoefficientsDataType,'Custom')





                    numNT=obj.CustomNumeratorCoefficientsDataType;
                    denNT=obj.CustomDenominatorCoefficientsDataType;
                    svsNT=obj.CustomScaleValuesDataType;


                    customPropNames=['CustomNumeratorCoefficientsDataType, '...
                    ,'CustomDenominatorCoefficientsDataType, and ',...
                    'CustomScaleValuesDataType'];

                    coder.internal.errorIf((...
                    numNT.WordLength~=denNT.WordLength||...
                    numNT.WordLength~=svsNT.WordLength),...
                    'dsp:dsp:private:FilterSystemObjectBase:InvalidDifferentWL',...
                    customPropNames);
                else



                    propNames=['NumeratorCoefficientsDataType, '...
                    ,'DenominatorCoefficientsDataType, and ScaleValuesDataType'];
                    defNT=getCoefficientsDataType(obj,'sos',propNames);
                    numNT=defNT;
                    denNT=defNT;
                    svsNT=defNT;
                end


                d.CoeffWordLength=numNT.WordLength;

                if isLocked(obj)



                    fixedpointinfo=getCompiledFixedPointInfo(obj);

                    if isprop(d,'StateAutoScale')
                        d.StateAutoScale=false;
                    end

                    if isprop(d,'SectionInputAutoScale')
                        d.SectionInputAutoScale=false;
                    end

                    if isprop(d,'SectionOutputAutoScale')
                        d.SectionOutputAutoScale=false;
                    end

                    fxpNumNT=fixedpointinfo.NumeratorCoefficientsDataType;
                    if strcmp(fxpNumNT.DataType,'Fixed')
                        fxpDenNT=fixedpointinfo.DenominatorCoefficientsDataType;
                        fxpSVlNT=fixedpointinfo.ScaleValuesDataType;
                        d.CoeffAutoScale=false;
                        d.NumFracLength=fxpNumNT.FractionLength;
                        d.DenFracLength=fxpDenNT.FractionLength;
                        d.ScaleValueFracLength=fxpSVlNT.FractionLength;
                    end

                    if strcmp(obj.Structure,'Direct form I')==0
                        d.SectionInputWordLength=fixedpointinfo.SectionInputDataType.WordLength;
                        d.SectionInputFracLength=fixedpointinfo.SectionInputDataType.FractionLength;

                        d.SectionOutputWordLength=fixedpointinfo.SectionOutputDataType.WordLength;
                        d.SectionOutputFracLength=fixedpointinfo.SectionOutputDataType.FractionLength;
                    else
                        d.NumStateWordLength=fixedpointinfo.SectionInputDataType.WordLength;
                        d.NumStateFracLength=fixedpointinfo.SectionInputDataType.FractionLength;

                        d.DenStateWordLength=fixedpointinfo.SectionOutputDataType.WordLength;
                        d.DenStateFracLength=fixedpointinfo.SectionOutputDataType.FractionLength;
                    end

                    if strcmp(obj.Structure,'Direct form I transposed')==1
                        d.MultiplicandWordLength=fixedpointinfo.MultiplicandDataType.WordLength;
                        d.MultiplicandFracLength=fixedpointinfo.MultiplicandDataType.FractionLength;

                        d.StateWordLength=fixedpointinfo.NumeratorStateDataType.WordLength;
                        d.NumStateFracLength=fixedpointinfo.NumeratorStateDataType.FractionLength;
                        d.DenStateFracLength=fixedpointinfo.DenominatorStateDataType.FractionLength;
                    end

                    if strcmp(obj.Structure,'Direct form II')==1||...
                        strcmp(obj.Structure,'Direct form II transposed')==1
                        d.StateWordLength=fixedpointinfo.StateDataType.WordLength;
                        d.StateFracLength=fixedpointinfo.StateDataType.FractionLength;
                    end

                    d.ProductMode='SpecifyPrecision';
                    d.ProductWordLength=fixedpointinfo.NumeratorProductDataType.WordLength;
                    d.NumProdFracLength=fixedpointinfo.NumeratorProductDataType.FractionLength;
                    d.DenProdFracLength=fixedpointinfo.DenominatorProductDataType.FractionLength;

                    d.AccumMode='SpecifyPrecision';
                    d.AccumWordLength=fixedpointinfo.NumeratorAccumulatorDataType.WordLength;
                    d.NumAccumFracLength=fixedpointinfo.NumeratorAccumulatorDataType.FractionLength;
                    d.DenAccumFracLength=fixedpointinfo.DenominatorAccumulatorDataType.FractionLength;

                    d.OutputMode='SpecifyPrecision';
                    d.OutputWordLength=fixedpointinfo.OutputDataType.WordLength;
                    d.OutputFracLength=fixedpointinfo.OutputDataType.FractionLength;

                else

























                    d.CoeffAutoScale=false;


                    if isbinarypointscalingset(numNT)
                        d.NumFracLength=numNT.FractionLength;
                    else


                        bMtrx=d.sosMatrix(:,1:3);
                        tmpNT=numerictype(fi(bMtrx,1,d.CoeffWordLength));
                        d.NumFracLength=tmpNT.FractionLength;
                    end


                    if isbinarypointscalingset(denNT)
                        d.DenFracLength=denNT.FractionLength;
                    else



                        aMtrx=d.sosMatrix(:,5:6);

                        tmpNT=numerictype(fi(aMtrx,1,d.CoeffWordLength));
                        d.DenFracLength=tmpNT.FractionLength;
                    end


                    if isbinarypointscalingset(svsNT)
                        d.ScaleValueFracLength=svsNT.FractionLength;
                    else


                        tmpNT=numerictype(fi(d.ScaleValues,1,d.CoeffWordLength));
                        d.ScaleValueFracLength=tmpNT.FractionLength;
                    end

                end


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


        function s=saveObjectImpl(obj)
            s=saveObjectImpl@matlab.system.SFunSystem(obj);
            s=saveFA(obj,s);
        end


        function loadObjectImpl(obj,s,wasLocked)
            loadObjectImpl@matlab.system.SFunSystem(obj,s);
            loadFA(obj,s,wasLocked);
        end
    end

    methods(Static)
        function helpFixedPoint






            matlab.system.dispFixptHelp('dsp.BiquadFilter',dsp.BiquadFilter.getDisplayFixedPointPropertiesImpl);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='dsparch4/Biquad Filter';
        end

        function props=getDisplayPropertiesImpl()
            props={...
            'Structure',...
            'SOSMatrixSource',...
            'SOSMatrix',...
            'ScaleValues',...
            'InitialConditions',...
            'NumeratorInitialConditions',...
            'DenominatorInitialConditions',...
            'OptimizeUnityScaleValues',...
            'ScaleValuesInputPort'};
        end

        function props=getDisplayFixedPointPropertiesImpl()
            props={...
            'RoundingMethod','OverflowAction',...
            'MultiplicandDataType','CustomMultiplicandDataType',...
            'SectionInputDataType','CustomSectionInputDataType',...
            'SectionOutputDataType','CustomSectionOutputDataType',...
            'NumeratorCoefficientsDataType','CustomNumeratorCoefficientsDataType',...
            'DenominatorCoefficientsDataType','CustomDenominatorCoefficientsDataType',...
            'ScaleValuesDataType','CustomScaleValuesDataType',...
            'NumeratorProductDataType','CustomNumeratorProductDataType',...
            'DenominatorProductDataType','CustomDenominatorProductDataType',...
            'NumeratorAccumulatorDataType','CustomNumeratorAccumulatorDataType',...
            'DenominatorAccumulatorDataType','CustomDenominatorAccumulatorDataType',...
            'StateDataType','CustomStateDataType',...
            'NumeratorStateDataType','CustomNumeratorStateDataType',...
            'DenominatorStateDataType','CustomDenominatorStateDataType',...
            'OutputDataType','CustomOutputDataType'};
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

end

function errIfNotValidCoeffSource(obj)
    if strcmp(obj.SOSMatrixSource,'Input port')
        error(message('dsp:dsp:private:FilterSystemObjectBase:HDLBiquadInputPortError'));
    end
end

function errIfNonZeroInitialConditions(obj)

    if(strncmpi(obj.Structure,'Direct Form II',14)&&~all(obj.InitialConditions==0))||...
        ~all(obj.NumeratorInitialConditions==0)||...
        ~all(obj.DenominatorInitialConditions==0)
        error(message('dsp:dsp:private:FilterSystemObjectBase:HDLNonZeroICError'));
    end
end


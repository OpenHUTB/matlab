classdef SOSFilter<matlab.system.SFunSystem&dsp.internal.FilterAnalysis


























































































%#codegen


%#function mdspsosfilter

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)




        Structure='Direct form II transposed';



        CoefficientSource='Property';
    end

    properties(Dependent,Hidden,SetAccess=private)
        SOSMatrix;
    end

    properties






        Numerator=[0.0975,0.195,0.0975];










        Denominator=[1,-0.94280904158206335630,(1/3)];











        ScaleValues=[1,1];
    end

    properties(Nontunable)




        HasScaleValues(1,1)logical=false;







        RoundingMethod='Floor';



        OverflowAction='Wrap';








        SectionInputDataType='Same as input';








        SectionOutputDataType='Same as section input';









        NumeratorDataType='Same word length as input';








        DenominatorDataType='Same word length as input';










        ScaleValuesDataType='Same word length as input';








        StateDataType='Full precision';









        MultiplicandDataType='Same as output';






        DenominatorAccumulatorDataType=numerictype(1,64,48);






        OutputDataType='Full precision';
    end

    properties(Constant,Hidden)
        CoefficientSourceSet=dsp.CommonSets.getSet('PropertyOrInputPort');

        StructureSet=matlab.system.StringSet(...
        {'Direct form I',...
        'Direct form I transposed',...
        'Direct form II',...
        'Direct form II transposed'});


        RoundingMethodSet=dsp.CommonSets.getSet('RoundingMethod');
        OverflowActionSet=dsp.CommonSets.getSet('OverflowAction');


        SectionInputDataTypeSet=...
        matlab.system.internal.DataTypeSet(...
        {'Same as input',...
        matlab.system.internal.CustomDataType(...
        'Signedness',{'Signed'},'Scaling',{'BinaryPoint'})});

        SectionOutputDataTypeSet=...
        matlab.system.internal.DataTypeSet(...
        {'Same as section input',...
        matlab.system.internal.CustomDataType(...
        'Signedness',{'Signed'},'Scaling',{'BinaryPoint'})});

        NumeratorDataTypeSet=...
        matlab.system.internal.DataTypeSet(...
        {'Same word length as input',...
        matlab.system.internal.CustomDataType(...
        'Signedness',{'Signed'},'Scaling',...
        {'Unspecified','BinaryPoint'})});

        DenominatorDataTypeSet=...
        matlab.system.internal.DataTypeSet(...
        {'Same word length as input',...
        matlab.system.internal.CustomDataType(...
        'Signedness',{'Signed'},'Scaling',...
        {'Unspecified','BinaryPoint'})});

        ScaleValuesDataTypeSet=...
        matlab.system.internal.DataTypeSet(...
        {'Same word length as input',...
        matlab.system.internal.CustomDataType(...
        'Signedness',{'Signed'},'Scaling',...
        {'Unspecified','BinaryPoint'})});

        MultiplicandDataTypeSet=...
        matlab.system.internal.DataTypeSet(...
        {'Same as output',...
        matlab.system.internal.CustomDataType(...
        'Signedness',{'Signed'},'Scaling',{'BinaryPoint'})});

        StateDataTypeSet=...
        matlab.system.internal.DataTypeSet(...
        {'Full precision',...
        matlab.system.internal.CustomDataType(...
        'Signedness',{'Signed'},'Scaling',{'BinaryPoint'})});

        DenominatorAccumulatorDataTypeSet=...
        matlab.system.internal.CustomDataType(...
        'Signedness',{'Signed'},'Scaling',{'BinaryPoint'});

        OutputDataTypeSet=...
        matlab.system.internal.DataTypeSet(...
        {'Full precision',...
        matlab.system.internal.CustomDataType(...
        'Signedness',{'Signed'},'Scaling',{'BinaryPoint'})});
    end

    methods

        function obj=SOSFilter(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mdspsosfilter');
            setProperties(obj,nargin,varargin{:},'Numerator','Denominator');
            setFrameStatus(obj,true);
            setEmptyAllowedStatus(obj,true);
        end

        function set.CoefficientSource(obj,val)
            clearMetaData(obj)
            obj.CoefficientSource=val;
        end

        function set.Structure(obj,val)
            clearMetaData(obj)
            obj.Structure=val;
        end

        function sos=get.SOSMatrix(obj)
            sos=[obj.Numerator,obj.Denominator];
        end

        function set.Numerator(obj,val)

            validateattributes(val,{'numeric'},...
            {'finite','nonnan','nonempty','2d','ncols',3},...
            'SOSFilter','Numerator');

            clearMetaData(obj)
            obj.Numerator=val;







            numSecPlusOne=size(val,1)+1;
            existingSVals=obj.ScaleValues;%#ok
            numSValActual=numel(existingSVals);
            if numSecPlusOne>numSValActual
                clearMetaData(obj)
                numExtraOneNeed=numSecPlusOne-numSValActual;
                obj.ScaleValues=[existingSVals,cast(ones(1,numExtraOneNeed),'like',existingSVals)];%#ok
            elseif numSecPlusOne<numSValActual
                clearMetaData(obj)
                obj.ScaleValues=existingSVals(1:numSecPlusOne);%#ok
            end
        end

        function set.Denominator(obj,val)
            validateattributes(val,{'numeric'},...
            {'finite','nonnan','nonempty','2d'},...
            'SOSFilter','Denominator');



            clearMetaData(obj)
            if size(val,2)==2
                obj.Denominator=...
                [cast((ones(size(val,1),1)),'like',val),val(:,1:2)];
            elseif size(val,2)==3
                obj.Denominator=...
                [cast((ones(size(val,1),1)),'like',val),val(:,2:3)];
            else
                coder.internal.error(...
                'dsp:system:SOSFilter:incorrectNumCols',...
                size(val,2));
            end
        end

        function set.ScaleValues(obj,val)
            validateattributes(val,{'numeric'},...
            {'real','finite','nonnan','nonempty','positive','vector'},...
            'SOSFilter','ScaleValues');

            numSVlElems=numel(val);
            numSections=size(obj.Numerator,1);%#ok
            svlRelevant=...
            obj.HasScaleValues&&...
            strcmp(obj.CoefficientSource,'Property');%#ok

            if numSVlElems<=1




                if~isempty(coder.target)&&svlRelevant

                    coder.internal.error(...
                    'dsp:system:SOSFilter:scaleValuesDims',...
                    numSVlElems,numSections);
                else


                    clearMetaData(obj)
                    obj.ScaleValues=[val,ones(1,numSections)];
                end
            else

                if~isequal(numSVlElems,(numSections+1))&&svlRelevant

                    coder.internal.error(...
                    'dsp:system:SOSFilter:scaleValuesDims',...
                    numSVlElems,numSections);
                end
                clearMetaData(obj)
                obj.ScaleValues=val;
            end
        end




        function Hnew=scale(obj,varargin)









































































            [d,varargin]=parseArithmetic(obj,varargin);
            if strcmpi(d.Arithmetic,'fixed')
                d.OverflowMode=obj.OverflowAction;
            end
            scale(d,varargin{:});


            d=reffilter(d);


            obj.HasScaleValues=true;

            if nargout==0
                if isLocked(obj)
                    release(obj)
                    msg=getString(message('dsp:dsp:private:FilterSystemObjectBase:Coefficients'));
                    coder.internal.warning('dsp:dsp:private:FilterSystemObjectBase:Release',msg);
                end
                obj.Numerator=d.sosMatrix(:,1:3);
                obj.Denominator=d.sosMatrix(:,4:6);
                obj.ScaleValues=(d.ScaleValues).';

                setsysobjmetadata(d,obj);
            else
                Hnew=clone(obj);
                release(Hnew);
                Hnew.Numerator=d.sosMatrix(:,1:3);
                Hnew.Denominator=d.sosMatrix(:,4:6);
                Hnew.ScaleValues=(d.ScaleValues).';

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
                obj.Numerator=d.sosMatrix(:,1:3);
                obj.Denominator=d.sosMatrix(:,4:6);
                if obj.HasScaleValues

                    obj.ScaleValues=(d.ScaleValues).';
                end

                setsysobjmetadata(d,obj);
            else
                Hnew=clone(obj);
                release(Hnew);
                Hnew.Numerator=d.sosMatrix(:,1:3);
                Hnew.Denominator=d.sosMatrix(:,4:6);
                if Hnew.HasScaleValues
                    Hnew.ScaleValues=(d.ScaleValues).';
                end

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
                    dfiltSOSMatrix=H(idx).sosMatrix;
                    filterCell{idx}.Numerator=dfiltSOSMatrix(:,1:3);
                    filterCell{idx}.Denominator=dfiltSOSMatrix(:,4:6);
                    filterCell{idx}.ScaleValues=(H(idx).ScaleValues).';
                end
            else
                cumsec(d,varargin{:});
            end
        end












































































    end

    methods(Access=public,Hidden)
        function setParameters(obj)
            if strcmp(obj.CoefficientSource,'Property')

                CoeffSourceIdx=5;
            else


                CoeffSourceIdx=2;
            end

            FilterStructureIdx=getIndex(obj.StructureSet,...
            obj.Structure)-1;

            if obj.HasScaleValues
                ScaleValuesOptionIdx=1;
            else
                ScaleValuesOptionIdx=2;
            end


            if~(isreal(obj.Numerator)&&isreal(obj.Denominator))
                num=complex(obj.Numerator);
                den=complex(obj.Denominator);
            else
                num=obj.Numerator;
                den=obj.Denominator;
            end

            if isSizesOnlyCall(obj)
                obj.compSetParameters({...
                CoeffSourceIdx,...
                FilterStructureIdx,...
                num,...
                den,...
                obj.ScaleValues,...
                ScaleValuesOptionIdx,...
                0,...
                0,...
                0,...
                1,...
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

                obj.compSetParameters({...
                CoeffSourceIdx,...
                FilterStructureIdx,...
                num,...
                den,...
                obj.ScaleValues,...
                ScaleValuesOptionIdx,...
                0,...
                0,...
                0,...
                1,...
                0,...
                16,...
                15,...
                dtInfo.DenominatorFracLength,...
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
                2,...
                dtInfo.DenominatorAccumulatorFracLength,...
                dtInfo.StateFracLength,...
                dtInfo.NumeratorDataType,...
                dtInfo.NumeratorWordLength,...
                dtInfo.NumeratorFracLength,...
                5,...
                2,...
                2,...
                dtInfo.NumeratorAccumulatorDataType,...
                dtInfo.DenominatorAccumulatorWordLength,...
                dtInfo.NumeratorAccumulatorFracLength,...
                dtInfo.StateDataType,...
                dtInfo.StateWordLength,...
                dtInfo.StateFracLength,...
                dtInfo.OutputDataType,...
                dtInfo.OutputWordLength,...
                dtInfo.OutputFracLength,...
                dtInfo.RoundingMethod,...
                dtInfo.OverflowAction...
                });
            end
        end

        function flag=ishdlable(~)
            flag=false;
        end

        function flag=isPropertyActive(obj,prop)
            flag=~isInactivePropertyImpl(obj,prop);
        end

        function y=supportsUnboundedIO(~)
            y=true;
        end

        function props=getNonFixedPointProperties(~)
            props=dsp.SOSFilter.getDisplayPropertiesImpl;
        end

        function props=getFixedPointProperties(~)
            props=dsp.SOSFilter.getDisplayFixedPointPropertiesImpl;
        end

        function restrictionsCell=getFixedPointRestrictions(obj,prop)%#ok

            restrictionsCell={'AUTOSIGNED','SIGNED','SCALED'};
        end

        function trueOrFalse=dtPropsDoNotContainAnyNumerictypeObj(obj,typePropListPrefix)
            allTypePropsFullStr=strcat(typePropListPrefix,'DataType');
            for idx=1:numel(allTypePropsFullStr)
                thisDTPropStr=allTypePropsFullStr{idx};
                if isnumerictype(obj.(thisDTPropStr))

                    trueOrFalse=false;return;
                end
            end
            trueOrFalse=true;
        end

        function dtInfo=getSOSFixptDTypeInfo(obj,typePropListPrefix)
            allTypePropsFullStr=strcat(typePropListPrefix,'DataType');
            for idx=1:numel(allTypePropsFullStr)
                thisPrpDTMDStr=allTypePropsFullStr{idx};
                thisPrefixStr=typePropListPrefix{idx};
                thisPrpDTWLStr=strcat(thisPrefixStr,'WordLength');
                thisPrpDTFLStr=strcat(thisPrefixStr,'FracLength');
                strOrNumrcType=obj.(thisPrpDTMDStr);
                if isnumerictype(strOrNumrcType)

                    if isbinarypointscalingset(strOrNumrcType)
                        DT_MODE_SPECIFIED_BY_USER=0;
                        dtInfo.(thisPrpDTMDStr)=DT_MODE_SPECIFIED_BY_USER;
                    else
                        DT_MODE_SPECIFY_WORD_LENGTH=1;
                        dtInfo.(thisPrpDTMDStr)=DT_MODE_SPECIFY_WORD_LENGTH;
                    end
                    dtInfo.(thisPrpDTWLStr)=strOrNumrcType.WordLength;
                    dtInfo.(thisPrpDTFLStr)=strOrNumrcType.FractionLength;
                else

                    tmpDTI=getFixptDataTypeInfo(obj,{thisPrefixStr});
                    dtInfo.(thisPrpDTMDStr)=tmpDTI.(thisPrpDTMDStr);
                    dtInfo.(thisPrpDTWLStr)=tmpDTI.(thisPrpDTWLStr);
                    dtInfo.(thisPrpDTFLStr)=tmpDTI.(thisPrpDTFLStr);
                end
            end



            switch(obj.RoundingMethod)
            case 'Zero'
                dtInfo.RoundingMethod=0;
            case 'Nearest'
                dtInfo.RoundingMethod=1;
            case 'Ceiling'
                dtInfo.RoundingMethod=2;
            case 'Floor'
                dtInfo.RoundingMethod=3;
            case 'Simplest'
                dtInfo.RoundingMethod=4;
            case 'Round'
                dtInfo.RoundingMethod=5;
            otherwise

                dtInfo.RoundingMethod=6;
            end



            if strcmp(obj.OverflowAction,'Wrap')
                dtInfo.OverflowAction=1;
            else
                dtInfo.OverflowAction=2;
            end
        end

        function dtInfo=getFixedPointInfo(obj)





            DT_MODE_SPECIFIED_BY_USER=0;
            DT_MODE_SPECIFY_WORD_LENGTH=1;%#ok % WL only best precision
            DT_MODE_SAME_AS_INPUT=2;%#ok % 'Same as input'
            DT_MODE_SAME_AS_ACCUM=4;
            DT_MODE_INTERNAL_RULE=5;%#ok % 'Full precision'

            typePropListPrefix={...
            'Multiplicand',...
            'SectionInput',...
            'SectionOutput',...
            'Numerator',...
            'Denominator',...
            'ScaleValues',...
            'State',...
            'Output'};




            if dtPropsDoNotContainAnyNumerictypeObj(obj,typePropListPrefix)
                dtInfo=getFixptDataTypeInfo(obj,typePropListPrefix);
            else

                dtInfo=getSOSFixptDTypeInfo(obj,typePropListPrefix);
            end


            dtInfo.DenominatorAccumulatorDataType=DT_MODE_SPECIFIED_BY_USER;
            dtInfo.DenominatorAccumulatorWordLength=...
            obj.DenominatorAccumulatorDataType.WordLength;
            dtInfo.DenominatorAccumulatorFracLength=...
            obj.DenominatorAccumulatorDataType.FractionLength;


            dtInfo.NumeratorAccumulatorDataType=DT_MODE_SPECIFIED_BY_USER;
            dtInfo.NumeratorAccumulatorWordLength=...
            obj.DenominatorAccumulatorDataType.WordLength;
            dtInfo.NumeratorAccumulatorFracLength=...
            obj.DenominatorAccumulatorDataType.FractionLength;



            if strcmp(obj.Structure,'Direct form I transposed')

                dtInfo.StateDataType=DT_MODE_SPECIFIED_BY_USER;
                dtInfo.StateWordLength=16;
                dtInfo.StateFracLength=15;

            elseif strcmp(obj.Structure,'Direct form II')

                dtInfo.MultiplicandDataType=DT_MODE_SPECIFIED_BY_USER;
                dtInfo.MultiplicandWordLength=16;
                dtInfo.MultiplicandFracLength=15;

            else


                dtInfo.MultiplicandDataType=DT_MODE_SPECIFIED_BY_USER;
                dtInfo.MultiplicandWordLength=16;
                dtInfo.MultiplicandFracLength=15;


                dtInfo.StateDataType=DT_MODE_SPECIFIED_BY_USER;
                dtInfo.StateWordLength=16;
                dtInfo.StateFracLength=15;
            end

            if~(obj.HasScaleValues)

                dtInfo.SectionInputDataType=DT_MODE_SPECIFIED_BY_USER;
                dtInfo.SectionInputWordLength=16;
                dtInfo.SectionInputFracLength=15;

                dtInfo.SectionOutputDataType=DT_MODE_SPECIFIED_BY_USER;
                dtInfo.SectionOutputWordLength=16;
                dtInfo.SectionOutputFracLength=15;

                dtInfo.ScaleValuesDataType=DT_MODE_SPECIFIED_BY_USER;
                dtInfo.ScaleValuesWordLength=16;
                dtInfo.ScaleValuesFracLength=15;
            end







            if isnumerictype(obj.SectionInputDataType)
                dtInfo.SectionInputDataType=2;
            else
                dtInfo.SectionInputDataType=1;
            end
            if isnumerictype(obj.SectionOutputDataType)
                dtInfo.SectionOutputDataType=2;
            else
                dtInfo.SectionOutputDataType=1;
            end
            if isnumerictype(obj.MultiplicandDataType)
                dtInfo.MultiplicandDataType=2;
            else
                dtInfo.MultiplicandDataType=1;
            end





            if(dtInfo.StateDataType~=DT_MODE_SPECIFIED_BY_USER)
                dtInfo.StateDataType=DT_MODE_SAME_AS_ACCUM;
            end





            if(dtInfo.OutputDataType~=DT_MODE_SPECIFIED_BY_USER)
                dtInfo.OutputDataType=DT_MODE_SAME_AS_ACCUM;
            end
        end

        function[NumeratorProdType,...
            DenominatorProdType,...
            NumeratorAccumType,...
            DenominatorAccumType]=testGetProdAccumTypes(obj,arith)



            NumeratorProdType=[];
            DenominatorProdType=[];
            NumeratorAccumType=[];
            DenominatorAccumType=[];

            if isLocked(obj)&&strcmpi(arith,'fixed')



                fixedpointinfo=getCompiledFixedPointInfo(obj);
                ProdWL=fixedpointinfo.NumeratorProductDataType.WordLength;
                NumPrdFL=fixedpointinfo.NumeratorProductDataType.FractionLength;
                DenPrdFL=fixedpointinfo.DenominatorProductDataType.FractionLength;
                AccumWL=fixedpointinfo.NumeratorAccumulatorDataType.WordLength;
                NumAccFL=fixedpointinfo.NumeratorAccumulatorDataType.FractionLength;
                DenAccFL=fixedpointinfo.DenominatorAccumulatorDataType.FractionLength;

                NumeratorProdType=numerictype(1,ProdWL,NumPrdFL);
                DenominatorProdType=numerictype(1,ProdWL,DenPrdFL);
                NumeratorAccumType=numerictype(1,AccumWL,NumAccFL);
                DenominatorAccumType=numerictype(1,AccumWL,DenAccFL);
            end
        end

    end


    methods(Access=protected,Hidden)

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
            switch prop
            case{'StateDataType'}
                flag=~strcmp(obj.Structure,'Direct form II');

            case{'MultiplicandDataType'}
                flag=~strcmp(obj.Structure,'Direct form I transposed');

            case{'Numerator','NumeratorDataType',...
                'Denominator','DenominatorDataType',...
                'ScaleValues','ScaleValuesDataType'}
                flag=strcmp(obj.CoefficientSource,'Input port');

            otherwise
                flag=false;
            end

            if(flag==false)

                if~(obj.HasScaleValues)
                    flag=...
                    strcmp(prop,'ScaleValues')||...
                    strcmp(prop,'ScaleValuesDataType')||...
                    strcmp(prop,'SectionInputDataType')||...
                    strcmp(prop,'SectionOutputDataType');
                end
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

        function setPortDataTypeConnections(obj)
            setPortDataTypeConnection(obj,1,1);
        end

        function d=convertToDFILT(obj,arith)



            if~strcmp(obj.CoefficientSource,'Property')
                sendNoAvailableCoefficientsError(obj,'CoefficientSource');
            end

            switch obj.Structure
            case 'Direct form I'
                d=dfilt.df1sos;
            case 'Direct form I transposed'
                d=dfilt.df1tsos;
            case 'Direct form II'
                d=dfilt.df2sos;
            otherwise

                d=dfilt.df2tsos;
            end

            d.sosMatrix=[obj.Numerator,obj.Denominator];
            d.OptimizeScaleValues=1;
            d.Arithmetic=arith;
            d.PersistentMemory=true;
            if obj.HasScaleValues
                d.ScaleValues=obj.ScaleValues;
            end

            if strcmpi(arith,'fixed')


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

                if isLocked(obj)



                    fixedpointinfo=getCompiledFixedPointInfo(obj);


                    fxpNumNT=fixedpointinfo.NumeratorCoefficientsDataType;
                    isNumFxp=strcmp(fxpNumNT.DataType,'Fixed');


                    if obj.HasScaleValues
                        d.ScaleValues=(obj.ScaleValues).';
                        fxpSvsNT=fixedpointinfo.ScaleValuesDataType;
                    else



                        d.ScaleValues=1;
                        if isNumFxp
                            fxpSvsNT=numerictype(fi(1,1,fxpNumNT.WordLength));
                        else
                            fxpSvsNT=fxpNumNT;
                        end
                    end

                    if isNumFxp

                        fxpDenNT=fixedpointinfo.DenominatorCoefficientsDataType;

                        coder.internal.errorIf((...
                        fxpNumNT.WordLength~=fxpDenNT.WordLength||...
                        fxpNumNT.WordLength~=fxpSvsNT.WordLength),...
                        'dsp:dsp:private:FilterSystemObjectBase:InvalidDifferentWL',...
                        'NumeratorDataType, DenominatorDataType, and ScaleValuesDataType');

                        d.CoeffAutoScale=false;
                        d.CoeffWordLength=fxpNumNT.WordLength;
                        d.NumFracLength=fxpNumNT.FractionLength;
                        d.DenFracLength=fxpDenNT.FractionLength;
                        d.ScaleValueFracLength=fxpSvsNT.FractionLength;
                    end

                    if isprop(d,'StateAutoScale')
                        d.StateAutoScale=false;
                    end

                    if isprop(d,'SectionInputAutoScale')
                        d.SectionInputAutoScale=false;
                    end

                    if isprop(d,'SectionOutputAutoScale')
                        d.SectionOutputAutoScale=false;
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




                    defNT=getCoefficientsDataType(obj,'sos','NumeratorDataType');
                    numNT=defNT;
                    denNT=defNT;
                    svsNT=defNT;


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

            end

        end

    end


    methods(Static)

        function helpFixedPoint






            matlab.system.dispFixptHelp('dsp.SOSFilter',...
            dsp.SOSFilter.getDisplayFixedPointPropertiesImpl);
        end

    end


    methods(Static,Hidden)

        function a=getAlternateBlock
            a='dsparch4/Biquad Filter';
        end

        function props=getDisplayPropertiesImpl()
            props={...
            'Structure',...
            'CoefficientSource',...
            'Numerator',...
            'Denominator',...
            'HasScaleValues',...
'ScaleValues'
            };
        end

        function props=getDisplayFixedPointPropertiesImpl()
            props={...
            'RoundingMethod',...
            'OverflowAction',...
            'SectionInputDataType',...
            'SectionOutputDataType',...
            'NumeratorDataType',...
            'DenominatorDataType',...
            'ScaleValuesDataType',...
            'StateDataType',...
            'MultiplicandDataType',...
            'DenominatorAccumulatorDataType',...
            'OutputDataType'};
        end




        function tunePropsMap=getTunablePropertiesMap()
            tunePropsMap.Numerator=2;
            tunePropsMap.Denominator=3;
            tunePropsMap.ScaleValues=4;
        end

        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end



        function props=getValueOnlyProperties()
            props={'Numerator','Denominator'};
        end

        function[nnum,nSV]=makeScaleValuesRealAndPositive(num,SV)


            nSV=abs(SV);
            nnum=num;


            if any(imag(SV))


                z=SV./nSV;
            elseif any(SV<0)

                z=sign(SV);
            else
                z=1;
            end


            nnum(end,:)=nnum(end,:)*prod(z);
        end

    end

end

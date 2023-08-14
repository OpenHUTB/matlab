classdef IIRFilter<matlab.system.CoreBlockSystem&dsp.internal.FilterAnalysis
































































    properties




        Numerator=[1,1];




        Denominator=[1,0.1];





        InitialConditions=0;






        NumeratorInitialConditions=0;






        DenominatorInitialConditions=0;
    end

    properties(Nontunable)





        Structure='Direct form II transposed';




        RoundingMethod='Floor';



        OverflowAction='Wrap';




        StateDataType='Same as input';







        CustomStateDataType=numerictype([],16,15);





        NumeratorCoefficientsDataType='Same word length as input';








        CustomNumeratorCoefficientsDataType=numerictype([],16,15);





        DenominatorCoefficientsDataType='Same word length as input';








        CustomDenominatorCoefficientsDataType=numerictype([],16,15);





        NumeratorProductDataType='Full precision';








        CustomNumeratorProductDataType=numerictype([],32,30);





        DenominatorProductDataType='Full precision';








        CustomDenominatorProductDataType=numerictype([],32,30);





        NumeratorAccumulatorDataType='Full precision';








        CustomNumeratorAccumulatorDataType=numerictype([],32,30);





        DenominatorAccumulatorDataType='Full precision';








        CustomDenominatorAccumulatorDataType=numerictype([],32,30);




        OutputDataType='Same as input';







        CustomOutputDataType=numerictype([],16,15);





        MultiplicandDataType='Same as input';







        CustomMultiplicandDataType=numerictype([],16,15);
    end

    properties(Constant,Hidden)
        StructureSet=matlab.system.StringSet(...
        {'Direct form I',...
        'Direct form I transposed',...
        'Direct form II',...
        'Direct form II transposed'});
        RoundingMethodSet=dsp.CommonSets.getSet('RoundingMethod');
        OverflowActionSet=dsp.CommonSets.getSet('OverflowAction');
        StateDataTypeSet=dsp.CommonSets.getSet('FixptModeBasic');
        NumeratorCoefficientsDataTypeSet=dsp.CommonSets.getSet('FixptModeEitherScale');
        DenominatorCoefficientsDataTypeSet=dsp.CommonSets.getSet('FixptModeEitherScale');
        NumeratorProductDataTypeSet=dsp.CommonSets.getSet('FixptModeInherit');
        DenominatorProductDataTypeSet=dsp.CommonSets.getSet('FixptModeInherit');
        NumeratorAccumulatorDataTypeSet=dsp.CommonSets.getSet('FixptModeInheritProd');
        DenominatorAccumulatorDataTypeSet=dsp.CommonSets.getSet('FixptModeInheritProd');
        OutputDataTypeSet=dsp.CommonSets.getSet('FixptModeInherit');
        MultiplicandDataTypeSet=dsp.CommonSets.getSet('FixptModeBasic');
    end

    methods

        function obj=IIRFilter(varargin)
            coder.allowpcode('plain');
            obj=obj@matlab.system.CoreBlockSystem('DiscreteFilter');
            setProperties(obj,nargin,varargin{:});
        end
        function set.Structure(obj,val)

            obj.Structure=val;
        end
        function set.Numerator(obj,value)
            validateattributes(value,...
            {'numeric'},{'finite','nonempty','row'},'','Numerator');

            obj.Numerator=value;
        end
        function set.Denominator(obj,value)
            validateattributes(value,...
            {'numeric'},{'finite','nonempty','row'},'','Denominator');

            obj.Denominator=value;
        end
        function set.InitialConditions(obj,value)
            validateattributes(value,...
            {'numeric'},{'finite','nonempty'},'','InitialConditions');
            obj.InitialConditions=value;
        end
        function set.NumeratorInitialConditions(obj,value)
            validateattributes(value,...
            {'numeric'},{'finite','nonempty'},'','NumeratorInitialConditions');
            obj.NumeratorInitialConditions=value;
        end
        function set.DenominatorInitialConditions(obj,value)
            validateattributes(value,...
            {'numeric'},{'finite','nonempty'},'','DenominatorInitialConditions');
            obj.DenominatorInitialConditions=value;
        end
        function set.CustomStateDataType(obj,val)
            validateCustomDataType(obj,'CustomStateDataType',val,...
            getFixedPointRestrictions(obj,'CustomStateDataType'));
            obj.CustomStateDataType=val;
        end
        function set.CustomNumeratorCoefficientsDataType(obj,val)
            validateCustomDataType(obj,'CustomNumeratorCoefficientsDataType',val,...
            getFixedPointRestrictions(obj,'CustomNumeratorCoefficientsDataType'));
            obj.CustomNumeratorCoefficientsDataType=val;
        end
        function set.CustomDenominatorCoefficientsDataType(obj,val)
            validateCustomDataType(obj,'CustomDenominatorCoefficientsDataType',val,...
            getFixedPointRestrictions(obj,'CustomDenominatorCoefficientsDataType'));
            obj.CustomDenominatorCoefficientsDataType=val;
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
        function set.CustomOutputDataType(obj,val)
            validateCustomDataType(obj,'CustomOutputDataType',val,...
            getFixedPointRestrictions(obj,'CustomOutputDataType'));
            obj.CustomOutputDataType=val;
        end
        function set.CustomMultiplicandDataType(obj,val)
            validateCustomDataType(obj,'CustomMultiplicandDataType',val,...
            getFixedPointRestrictions(obj,'CustomMultiplicandDataType'));
            obj.CustomMultiplicandDataType=val;
        end

        function Hsos=sos(obj,varargin)















            [d,varargin]=parseArithmetic(obj,varargin,true);


            bqflag={};
            idx=find(strcmpi(varargin,'UseLegacyBiquadFilter'),1);
            if~isempty(idx)
                bqflag=varargin(idx:idx+1);
                varargin(idx:idx+1)=[];
            end

            hsos=sos(d,varargin{:});
            Hsos=sysobj(hsos,bqflag{:});
        end
    end

    methods(Hidden)
        function setParameters(obj)

            setFrameStatus(obj,true);

            inputProcessing='Columns as channels (frame based)';

            switch getIndex(obj.StructureSet,obj.Structure)
            case 1
                filterStructure='Direct form I';
            case 2
                filterStructure='Direct form I transposed';
            case 3
                filterStructure='Direct form II';
            case 4
                filterStructure='Direct form II transposed';
            end

            if getIndex(obj.StructureSet,obj.Structure)<3

                initialStates=obj.NumeratorInitialConditions;
            else

                initialStates=obj.InitialConditions;
            end
            if getIndex(obj.OverflowActionSet,obj.OverflowAction)==1
                saturateOnIntegerOverflow='off';
            else
                saturateOnIntegerOverflow='on';
            end


            if getIndex(obj.StateDataTypeSet,obj.StateDataType)==1
                stateDataTypeStr='Inherit: Same as input';
            else
                stateDataTypeStr=dsp.internal.createCustomDataTypeProps(...
                obj.CustomStateDataType);
            end

            if getIndex(obj.NumeratorCoefficientsDataTypeSet,obj.NumeratorCoefficientsDataType)==1
                numCoefDataTypeStr='Inherit: Inherit via internal rule';

            elseif(isnumerictype(obj.CustomNumeratorCoefficientsDataType)&&...
                strcmpi(obj.CustomNumeratorCoefficientsDataType.DataTypeMode,...
                'Fixed-point: unspecified scaling'))

                numCoefDataTypeStr=dsp.internal.createCustomDataTypeProps(...
                obj.CustomNumeratorCoefficientsDataType,obj.Numerator);

            else
                numCoefDataTypeStr=dsp.internal.createCustomDataTypeProps(...
                obj.CustomNumeratorCoefficientsDataType);
            end

            if getIndex(obj.DenominatorCoefficientsDataTypeSet,obj.DenominatorCoefficientsDataType)==1
                denCoefDataTypeStr='Inherit: Inherit via internal rule';

            elseif(isnumerictype(obj.CustomDenominatorCoefficientsDataType)&&...
                strcmpi(obj.CustomDenominatorCoefficientsDataType.DataTypeMode,...
                'Fixed-point: unspecified scaling'))

                denCoefDataTypeStr=dsp.internal.createCustomDataTypeProps(...
                obj.CustomDenominatorCoefficientsDataType,obj.Denominator);

            else
                denCoefDataTypeStr=dsp.internal.createCustomDataTypeProps(...
                obj.CustomDenominatorCoefficientsDataType);
            end

            if getIndex(obj.NumeratorProductDataTypeSet,obj.NumeratorProductDataType)==1
                numProductDataTypeStr='Inherit: Inherit via internal rule';
            elseif getIndex(obj.NumeratorProductDataTypeSet,obj.NumeratorProductDataType)==2
                numProductDataTypeStr='Inherit: Same as input';
            else
                numProductDataTypeStr=dsp.internal.createCustomDataTypeProps(...
                obj.CustomNumeratorProductDataType);
            end
            if getIndex(obj.DenominatorProductDataTypeSet,obj.DenominatorProductDataType)==1
                denProductDataTypeStr='Inherit: Inherit via internal rule';
            elseif getIndex(obj.DenominatorProductDataTypeSet,obj.DenominatorProductDataType)==2
                denProductDataTypeStr='Inherit: Same as input';
            else
                denProductDataTypeStr=dsp.internal.createCustomDataTypeProps(...
                obj.CustomDenominatorProductDataType);
            end
            if getIndex(obj.NumeratorAccumulatorDataTypeSet,obj.NumeratorAccumulatorDataType)==1
                numAccumDataTypeStr='Inherit: Inherit via internal rule';
            elseif getIndex(obj.NumeratorAccumulatorDataTypeSet,obj.NumeratorAccumulatorDataType)==2



                numAccumDataTypeStr='Inherit: Same as product output';
            elseif getIndex(obj.NumeratorAccumulatorDataTypeSet,obj.NumeratorAccumulatorDataType)==3
                numAccumDataTypeStr='Inherit: Same as input';
            else
                numAccumDataTypeStr=dsp.internal.createCustomDataTypeProps(...
                obj.CustomNumeratorAccumulatorDataType);
            end
            if getIndex(obj.DenominatorAccumulatorDataTypeSet,obj.DenominatorAccumulatorDataType)==1
                denAccumDataTypeStr='Inherit: Inherit via internal rule';
            elseif getIndex(obj.DenominatorAccumulatorDataTypeSet,obj.DenominatorAccumulatorDataType)==2



                denAccumDataTypeStr='Inherit: Same as product output';
            elseif getIndex(obj.DenominatorAccumulatorDataTypeSet,obj.DenominatorAccumulatorDataType)==3
                denAccumDataTypeStr='Inherit: Same as input';
            else
                denAccumDataTypeStr=dsp.internal.createCustomDataTypeProps(...
                obj.CustomDenominatorAccumulatorDataType);
            end
            if getIndex(obj.OutputDataTypeSet,obj.OutputDataType)==1
                outDataTypeStr='Inherit: Inherit via internal rule';
            elseif getIndex(obj.OutputDataTypeSet,obj.OutputDataType)==2
                outDataTypeStr='Inherit: Same as input';
            else
                outDataTypeStr=dsp.internal.createCustomDataTypeProps(...
                obj.CustomOutputDataType);
            end
            if getIndex(obj.MultiplicandDataTypeSet,obj.MultiplicandDataType)==1
                multiplicandDataTypeStr='Inherit: Same as input';
            else
                multiplicandDataTypeStr=dsp.internal.createCustomDataTypeProps(...
                obj.CustomMultiplicandDataType);
            end
            obj.compSetParameters({...
            'Dialog parameters',...
            obj.Numerator,...
            'Dialog parameters',...
            obj.Denominator,...
            'Dialog parameters',...
            initialStates,...
            inputProcessing,...
            'None',...
            obj.DenominatorInitialConditions,...
            filterStructure,...
            -1,...
            'on',...
            'auto',...
            [],[],[],[],[],[],...
            stateDataTypeStr,...
            multiplicandDataTypeStr,...
            numCoefDataTypeStr,...
            denCoefDataTypeStr,...
            numProductDataTypeStr,...
            denProductDataTypeStr,...
            numAccumDataTypeStr,...
            denAccumDataTypeStr,...
            outDataTypeStr,...
            'off',...
            obj.RoundingMethod,...
            saturateOnIntegerOverflow,...
            '',...
            'off',...
            'Auto',...
            '--- None ---',...
            '',...
            '',...
            '',...
            '',...
            'double',...
            'double',...
            'double',...
            'double',...
            'double',...
            'double',...
            'double',...
            'double',...
            '',...
            '',...
            '',...
            '',...
            '',...
            '',...
            });
        end
        function restrictionsCell=getFixedPointRestrictions(obj,prop)
            switch prop
            case{'CustomStateDataType',...
                'CustomNumeratorProductDataType',...
                'CustomDenominatorProductDataType',...
                'CustomNumeratorAccumulatorDataType',...
                'CustomDenominatorAccumulatorDataType',...
                'CustomOutputDataType',...
                'CustomMultiplicandDataType'}
                restrictionsCell={'AUTOSIGNED','SCALED'};
            case{'CustomNumeratorCoefficientsDataType',...
                'CustomDenominatorCoefficientsDataType'}
                restrictionsCell={'AUTOSIGNED'};
            otherwise
                error(message('dsp:dsp:private:FilterSystemObjectBase:InvalidProperty',prop,class(obj)))
            end
        end
        function props=getNonFixedPointProperties(~)
            props=dsp.IIRFilter.getDisplayPropertiesImpl;
        end
        function props=getFixedPointProperties(~)
            props=dsp.IIRFilter.getDisplayFixedPointPropertiesImpl;
        end
        function flag=isPropertyActive(obj,prop)
            flag=~isInactivePropertyImpl(obj,prop);
        end
    end

    methods(Access=protected)
        function validateInputsImpl(obj,varargin)

            if~isempty(varargin)
                inputData=varargin{1};
                cacheInputDataType(obj,inputData)
            end
        end
        function flag=isInactivePropertyImpl(obj,prop)
            switch getIndex(obj.StructureSet,obj.Structure)
            case 1

                props={'InitialConditions','MultiplicandDataType',...
                'CustomMultiplicandDataType','StateDataType','CustomStateDataType'};
            case 2

                props={'InitialConditions'};
                if~matlab.system.isSpecifiedTypeMode(obj.MultiplicandDataType)
                    props{end+1}='CustomMultiplicandDataType';
                end
                if~matlab.system.isSpecifiedTypeMode(obj.StateDataType)
                    props{end+1}='CustomStateDataType';
                end
            case{3,4}

                props={'NumeratorInitialConditions','DenominatorInitialConditions',...
                'MultiplicandDataType','CustomMultiplicandDataType'};
                if~matlab.system.isSpecifiedTypeMode(obj.StateDataType)
                    props{end+1}='CustomStateDataType';
                end
            end
            if~matlab.system.isSpecifiedTypeMode(obj.NumeratorCoefficientsDataType)
                props{end+1}='CustomNumeratorCoefficientsDataType';
            end
            if~matlab.system.isSpecifiedTypeMode(obj.DenominatorCoefficientsDataType)
                props{end+1}='CustomDenominatorCoefficientsDataType';
            end
            if~matlab.system.isSpecifiedTypeMode(obj.NumeratorProductDataType)
                props{end+1}='CustomNumeratorProductDataType';
            end
            if~matlab.system.isSpecifiedTypeMode(obj.DenominatorProductDataType)
                props{end+1}='CustomDenominatorProductDataType';
            end
            if~matlab.system.isSpecifiedTypeMode(obj.NumeratorAccumulatorDataType)
                props{end+1}='CustomNumeratorAccumulatorDataType';
            end
            if~matlab.system.isSpecifiedTypeMode(obj.DenominatorAccumulatorDataType)
                props{end+1}='CustomDenominatorAccumulatorDataType';
            end
            if~matlab.system.isSpecifiedTypeMode(obj.OutputDataType)
                props{end+1}='CustomOutputDataType';
            end
            flag=ismember(prop,props);
        end
        function y=infoImpl(obj,varargin)
            y=infoFA(obj,varargin{:});
        end
        function setPortDataTypeConnections(obj)
            setPortDataTypeConnection(obj,1,1);
        end

        function d=convertToDFILT(obj,arith)


            switch obj.Structure
            case 'Direct form I'
                d=dfilt.df1;
            case 'Direct form I transposed'
                d=dfilt.df1t;
            case 'Direct form II'
                d=dfilt.df2;
            case 'Direct form II transposed'
                d=dfilt.df2t;
            end

            d.Numerator=obj.Numerator;
            d.Denominator=obj.Denominator;
            d.Arithmetic=arith;
            d.PersistentMemory=true;

            if strcmpi(arith,'fixed')
                if strcmpi(obj.NumeratorCoefficientsDataType,'Custom')
                    numeratorNumericType=obj.CustomNumeratorCoefficientsDataType;
                else



                    propNames='NumeratorCoefficientsDataType';
                    numeratorNumericType=getCoefficientsDataType(obj,'iir',propNames);
                end
                if strcmpi(obj.DenominatorCoefficientsDataType,'Custom')
                    denominatorNumericType=obj.CustomDenominatorCoefficientsDataType;
                else
                    propNames='DenominatorCoefficientsDataType';
                    denominatorNumericType=getCoefficientsDataType(obj,'iir',propNames);
                end

                coder.internal.errorIf(...
                numeratorNumericType.WordLength~=denominatorNumericType.WordLength,...
                'dsp:dsp:private:FilterSystemObjectBase:InvalidDifferentWLIIR');

                d.CoeffWordLength=numeratorNumericType.WordLength;


                isScaledNumerator=isbinarypointscalingset(numeratorNumericType);
                isScaledDenominator=isbinarypointscalingset(denominatorNumericType);
                idx=sum([isScaledNumerator,isScaledDenominator]);




                if idx>0
                    d.CoeffAutoScale=false;
                    if isScaledNumerator
                        d.NumFracLength=numeratorNumericType.FractionLength;
                    end
                    if isScaledDenominator
                        d.DenFracLength=denominatorNumericType.FractionLength;
                    end
                end
            end
        end

        function s=saveObjectImpl(obj)
            s=saveObjectImpl@matlab.system.CoreBlockSystem(obj);
            s=saveFA(obj,s);
        end

        function loadObjectImpl(obj,s,wasLocked)
            loadObjectImpl@matlab.system.CoreBlockSystem(obj,s);
            loadFA(obj,s,wasLocked);
        end

    end

    methods(Static)
        function helpFixedPoint






            matlab.system.dispFixptHelp('dsp.IIRFilter',...
            dsp.IIRFilter.getDisplayFixedPointPropertiesImpl);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='dsparch4/Discrete Filter';
        end

        function b=generatesCode
            b=true;
        end
        function props=getDisplayPropertiesImpl()
            props={'Structure',...
            'Numerator',...
            'Denominator',...
            'InitialConditions',...
            'NumeratorInitialConditions',...
            'DenominatorInitialConditions'};
        end
        function props=getDisplayFixedPointPropertiesImpl()
            props={...
            'RoundingMethod','OverflowAction',...
            'StateDataType','CustomStateDataType',...
            'NumeratorCoefficientsDataType','CustomNumeratorCoefficientsDataType',...
            'DenominatorCoefficientsDataType','CustomDenominatorCoefficientsDataType',...
            'NumeratorProductDataType','CustomNumeratorProductDataType',...
            'DenominatorProductDataType','CustomDenominatorProductDataType',...
            'NumeratorAccumulatorDataType','CustomNumeratorAccumulatorDataType',...
            'DenominatorAccumulatorDataType','CustomDenominatorAccumulatorDataType',...
            'OutputDataType','CustomOutputDataType',...
            'MultiplicandDataType','CustomMultiplicandDataType'};
        end



        function tunePropsMap=getTunablePropertiesMap()
            tunePropsMap.Numerator=1;
            tunePropsMap.Denominator=3;









        end
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end
end

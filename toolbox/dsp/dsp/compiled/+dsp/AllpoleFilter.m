classdef AllpoleFilter<matlab.system.CoreBlockSystem&dsp.internal.FilterAnalysis




























































    properties





        Denominator=[1.0,0.1];





        ReflectionCoefficients=[0.2,0.4];



        InitialConditions=0;
    end

    properties(Nontunable)




        Structure='Direct form';
    end

    properties(Nontunable)




        RoundingMethod='Floor';



        OverflowAction='Wrap';




        CoefficientsDataType='Same word length as input';







        CustomCoefficientsDataType=numerictype([],16,15);





        ReflectionCoefficientsDataType='Same word length as input';








        CustomReflectionCoefficientsDataType=numerictype([],16,15);




        ProductDataType='Full precision';







        CustomProductDataType=numerictype([],32,30);




        AccumulatorDataType='Full precision';







        CustomAccumulatorDataType=numerictype([],32,30);




        StateDataType='Same as accumulator';







        CustomStateDataType=numerictype([],16,15);




        OutputDataType='Same as input';







        CustomOutputDataType=numerictype([],16,15);
    end

    properties(Constant,Hidden)
        StructureSet=matlab.system.StringSet(...
        {'Direct form',...
        'Direct form transposed',...
        'Lattice AR'});
        RoundingMethodSet=dsp.CommonSets.getSet('RoundingMethod');
        OverflowActionSet=dsp.CommonSets.getSet('OverflowAction');

        CoefficientsDataTypeSet=dsp.CommonSets.getSet('FixptModeEitherScale');
        ReflectionCoefficientsDataTypeSet=dsp.CommonSets.getSet('FixptModeEitherScale');
        ProductDataTypeSet=dsp.CommonSets.getSet('FixptModeInherit');
        AccumulatorDataTypeSet=dsp.CommonSets.getSet('FixptModeInheritProd');
        OutputDataTypeSet=dsp.CommonSets.getSet('FixptModeAccum');
        StateDataTypeSet=dsp.CommonSets.getSet('FixptModeAccum');

    end

    methods

        function obj=AllpoleFilter(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.CoreBlockSystem('AllpoleFilter');
            setProperties(obj,nargin,varargin{:});
            setVarSizeAllowedStatus(obj,true);
        end

        function set.Denominator(obj,value)
            validateattributes(value,...
            {'numeric'},{'finite','nonempty','row'},'','Denominator');

            obj.Denominator=value;
        end

        function set.ReflectionCoefficients(obj,value)
            validateattributes(value,...
            {'numeric'},{'finite','nonempty','row'},'','ReflectionCoefficients');

            obj.ReflectionCoefficients=value;
        end

        function set.Structure(obj,val)

            obj.Structure=val;
        end

        function set.InitialConditions(obj,value)
            validateattributes(value,...
            {'numeric'},{'finite','nonempty'},'','InitialConditions');
            obj.InitialConditions=value;
        end

        function set.CustomCoefficientsDataType(obj,val)
            validateCustomDataType(obj,'CustomCoefficientsDataType',val,...
            getFixedPointRestrictions(obj,'CustomCoefficientsDataType'));
            obj.CustomCoefficientsDataType=val;
        end

        function set.CustomReflectionCoefficientsDataType(obj,val)
            validateCustomDataType(obj,'CustomReflectionCoefficientsDataType',val,...
            getFixedPointRestrictions(obj,'CustomReflectionCoefficientsDataType'));
            obj.CustomReflectionCoefficientsDataType=val;
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

        function set.CustomStateDataType(obj,val)
            validateCustomDataType(obj,'CustomStateDataType',val,...
            getFixedPointRestrictions(obj,'CustomStateDataType'));
            obj.CustomStateDataType=val;
        end

        function set.CustomOutputDataType(obj,val)
            validateCustomDataType(obj,'CustomOutputDataType',val,...
            getFixedPointRestrictions(obj,'CustomOutputDataType'));
            obj.CustomOutputDataType=val;
        end

    end

    methods(Hidden)
        function y=supportsUnboundedIO(~)
            y=true;
        end

        function setParameters(obj)

            setFrameStatus(obj,true);

            InputProcessing='Columns as channels (frame based)';

            switch getIndex(obj.StructureSet,obj.Structure)
            case 1
                FilterStructure='Direct form';
            case 2
                FilterStructure='Direct form transposed';
            case 3
                FilterStructure='Lattice AR';
            end

            if getIndex(obj.StructureSet,obj.Structure)~=3

                Coefficients=obj.Denominator;
                if(getIndex(obj.CoefficientsDataTypeSet,...
                    obj.CoefficientsDataType)==1)

                    CoefDataTypeStr='Inherit: Same word length as input';

                elseif(isnumerictype(obj.CustomCoefficientsDataType)&&...
                    strcmp(obj.CustomCoefficientsDataType.DataTypeMode,...
                    'Fixed-point: unspecified scaling'))

                    CoefDataTypeStr=dsp.internal.createCustomDataTypeProps(...
                    obj.CustomCoefficientsDataType,Coefficients);

                else
                    CoefDataTypeStr=dsp.internal.createCustomDataTypeProps(...
                    obj.CustomCoefficientsDataType);
                end
            else
                Coefficients=obj.ReflectionCoefficients;
                if(getIndex(obj.ReflectionCoefficientsDataTypeSet,...
                    obj.ReflectionCoefficientsDataType)==1)

                    CoefDataTypeStr='Inherit: Same word length as input';

                elseif(isnumerictype(obj.CustomReflectionCoefficientsDataType)&&...
                    strcmp(obj.CustomReflectionCoefficientsDataType.DataTypeMode,...
                    'Fixed-point: unspecified scaling'))

                    CoefDataTypeStr=dsp.internal.createCustomDataTypeProps(...
                    obj.CustomReflectionCoefficientsDataType,Coefficients);

                else
                    CoefDataTypeStr=dsp.internal.createCustomDataTypeProps(...
                    obj.CustomReflectionCoefficientsDataType);
                end
            end

            if getIndex(obj.OverflowActionSet,obj.OverflowAction)==1
                SaturateOnIntegerOverflow='off';
            else
                SaturateOnIntegerOverflow='on';
            end


            if getIndex(obj.ProductDataTypeSet,obj.ProductDataType)==1
                ProductDataTypeStr='Inherit: Inherit via internal rule';
            elseif getIndex(obj.ProductDataTypeSet,obj.ProductDataType)==2
                ProductDataTypeStr='Inherit: Same as input';
            else
                ProductDataTypeStr=dsp.internal.createCustomDataTypeProps(...
                obj.CustomProductDataType);
            end


            if getIndex(obj.AccumulatorDataTypeSet,obj.AccumulatorDataType)==1
                AccumDataTypeStr='Inherit: Inherit via internal rule';
            elseif getIndex(obj.AccumulatorDataTypeSet,obj.AccumulatorDataType)==2



                AccumDataTypeStr='Inherit: Same as product output';
            elseif getIndex(obj.AccumulatorDataTypeSet,obj.AccumulatorDataType)==3
                AccumDataTypeStr='Inherit: Same as input';
            else
                AccumDataTypeStr=dsp.internal.createCustomDataTypeProps(...
                obj.CustomAccumulatorDataType);
            end


            if getIndex(obj.OutputDataTypeSet,obj.OutputDataType)==1
                OutDataTypeStr='Inherit: Same as accumulator';
            elseif getIndex(obj.OutputDataTypeSet,obj.OutputDataType)==2
                OutDataTypeStr='Inherit: Same as input';
            else
                OutDataTypeStr=dsp.internal.createCustomDataTypeProps(...
                obj.CustomOutputDataType);
            end


            if getIndex(obj.StateDataTypeSet,obj.StateDataType)==1
                StateDataTypeStr='Inherit: Same as accumulator';
            elseif getIndex(obj.StateDataTypeSet,obj.StateDataType)==2
                StateDataTypeStr='Inherit: Same as input';
            else
                StateDataTypeStr=dsp.internal.createCustomDataTypeProps(...
                obj.CustomStateDataType);
            end

            obj.compSetParameters({...
            'Dialog parameters',...
            'on',...
            FilterStructure,...
            'Direct form',...
            Coefficients,...
            InputProcessing,...
            'none','false',...
            obj.InitialConditions,...
            -1,...
            [],[],...
            [],[],...
            'Inherit: Inherit via internal rule',...
            CoefDataTypeStr,...
            ProductDataTypeStr,...
            AccumDataTypeStr,...
            StateDataTypeStr,...
            OutDataTypeStr,...
            'off',...
            obj.RoundingMethod,...
            SaturateOnIntegerOverflow,...
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
            '',...
            '',...
            'off',...
            '',...
            '',...
            '',...
            '',...
            '',...
            '',...
            '',...
            });
        end
        function restrictionsCell=getFixedPointRestrictions(obj,prop)
            restrictionsCell={};
            switch prop
            case{'CustomProductDataType',...
                'CustomAccumulatorDataType',...
                'CustomOutputDataType',...
                'CustomStateDataType'}
                restrictionsCell={'AUTOSIGNED','SCALED'};
            case{'CustomCoefficientsDataType','CustomReflectionCoefficientsDataType'}
                restrictionsCell={'AUTOSIGNED'};
            otherwise
                coder.internal.errorIf(true,...
                'dsp:dsp:private:FilterSystemObjectBase:InvalidProperty',prop,class(obj));
            end
        end
        function props=getNonFixedPointProperties(~)
            props=dsp.AllpoleFilter.getDisplayPropertiesImpl;
        end
        function props=getFixedPointProperties(~)
            props=dsp.AllpoleFilter.getDisplayFixedPointPropertiesImpl;
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

            if getIndex(obj.StructureSet,obj.Structure)~=3

                props={'ReflectionCoefficients','ReflectionCoefficientsDataType',...
                'CustomReflectionCoefficientsDataType'};
                if getIndex(obj.StructureSet,obj.Structure)==1

                    props=[props,{'StateDataType','CustomStateDataType'}];
                end
                if~matlab.system.isSpecifiedTypeMode(obj.CoefficientsDataType)
                    props{end+1}='CustomCoefficientsDataType';
                end
            else

                props={'Denominator','CoefficientsDataType','CustomCoefficientsDataType'};
                if~matlab.system.isSpecifiedTypeMode(obj.ReflectionCoefficientsDataType)
                    props{end+1}='CustomReflectionCoefficientsDataType';
                end
            end

            if~matlab.system.isSpecifiedTypeMode(obj.ProductDataType)
                props{end+1}='CustomProductDataType';
            end
            if~matlab.system.isSpecifiedTypeMode(obj.AccumulatorDataType)
                props{end+1}='CustomAccumulatorDataType';
            end
            if~matlab.system.isSpecifiedTypeMode(obj.StateDataType)
                props{end+1}='CustomStateDataType';
            end
            if~matlab.system.isSpecifiedTypeMode(obj.OutputDataType)
                props{end+1}='CustomOutputDataType';
            end
            flag=ismember(prop,props);
        end

        function y=infoImpl(obj,varargin)
            y=infoFA(obj,varargin{:});
        end

        function d=convertToDFILT(obj,arith)

            switch obj.Structure
            case{'Direct form','Direct form transposed'}
                if strcmpi(arith,'double')
                    switch obj.Structure
                    case 'Direct form'
                        d=dfilt.df1;
                    case 'Direct form transposed'
                        d=dfilt.df1t;
                    end
                    d.Numerator=1;
                    d.Denominator=obj.Denominator;
                    return;
                else
                    error(message(...
                    'dsp:dsp:private:FilterSystemObjectBase:InvalidAllpoleStructureAnalysis'));
                end
            case 'Lattice AR'
                d=dfilt.latticear;
                d.Lattice=obj.ReflectionCoefficients;
            end

            d.Arithmetic=arith;
            d.PersistentMemory=true;

            if strcmpi(arith,'fixed')
                if strcmpi(obj.ReflectionCoefficientsDataType,'Custom')
                    coeffsNumericType=obj.CustomReflectionCoefficientsDataType;
                else



                    coeffsNumericType=getCoefficientsDataType(obj,'AR','ReflectionCoefficientsDataType');
                end

                d.CoeffWordLength=coeffsNumericType.WordLength;


                if isbinarypointscalingset(coeffsNumericType)
                    d.CoeffAutoScale=false;
                    d.LatticeFracLength=coeffsNumericType.FractionLength;
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






            matlab.system.dispFixptHelp('dsp.AllpoleFilter',...
            dsp.AllpoleFilter.getDisplayFixedPointPropertiesImpl);
        end
    end

    methods(Access=protected)
        function setPortDataTypeConnections(obj)
            setPortDataTypeConnection(obj,1,1);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='dsparch4/Allpole Filter';
        end

        function props=getDisplayPropertiesImpl()
            props={...
            'Structure',...
            'Denominator',...
            'ReflectionCoefficients',...
            'InitialConditions'};
        end

        function props=getDisplayFixedPointPropertiesImpl()
            props={...
            'RoundingMethod','OverflowAction',...
            'CoefficientsDataType','CustomCoefficientsDataType',...
            'ReflectionCoefficientsDataType','CustomReflectionCoefficientsDataType',...
            'ProductDataType','CustomProductDataType',...
            'AccumulatorDataType','CustomAccumulatorDataType',...
            'StateDataType','CustomStateDataType',...
            'OutputDataType','CustomOutputDataType'};
        end



        function tunePropsMap=getTunablePropertiesMap()
            tunePropsMap.Denominator=4;







        end
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end

end

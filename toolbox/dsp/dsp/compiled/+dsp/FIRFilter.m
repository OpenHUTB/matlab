classdef FIRFilter<matlab.system.CoreBlockSystem&dsp.internal.FilterAnalysis






























































































    properties







        Numerator=[0.5,0.5];






        ReflectionCoefficients=[0.5,0.5];





        InitialConditions=0;
    end

    properties(Nontunable)





        NumeratorSource='Property';





        ReflectionCoefficientsSource='Property';




        Structure='Direct form';










        FullPrecisionOverride(1,1)logical=true;





        RoundingMethod='Floor';



        OverflowAction='Wrap';





        CoefficientsDataType='Same word length as input';






        ReflectionCoefficientsDataType='Same word length as input';








        CustomCoefficientsDataType=numerictype(true,16,15);









        CustomReflectionCoefficientsDataType=numerictype(true,16,15);






        ProductDataType='Full precision';









        CustomProductDataType=numerictype(true,32,30);






        AccumulatorDataType='Full precision';








        CustomAccumulatorDataType=numerictype(true,32,30);






        StateDataType='Same as accumulator';








        CustomStateDataType=numerictype(true,16,15);






        OutputDataType='Same as accumulator';








        CustomOutputDataType=numerictype(true,16,15);
    end

    properties(Nontunable,Hidden)




        CoderTarget='MATLAB';
    end

    properties(Constant,Hidden)
        StructureSet=matlab.system.StringSet(...
        {'Direct form',...
        'Direct form symmetric',...
        'Direct form antisymmetric',...
        'Direct form transposed',...
        'Lattice MA'});
        NumeratorSourceSet=dsp.CommonSets.getSet('PropertyOrInputPort');
        ReflectionCoefficientsSourceSet=dsp.CommonSets.getSet('PropertyOrInputPort');
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

        function obj=FIRFilter(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.CoreBlockSystem('DiscreteFir');
            setProperties(obj,nargin,varargin{:},'Numerator');
            setVarSizeAllowedStatus(obj,true);
        end

        function set.CoderTarget(obj,val)
            obj.CoderTarget=val;
        end

        function set.NumeratorSource(obj,val)
            clearMetaData(obj)
            obj.NumeratorSource=val;
        end

        function set.ReflectionCoefficientsSource(obj,val)
            clearMetaData(obj)
            obj.ReflectionCoefficientsSource=val;
        end

        function set.Numerator(obj,value)
            if isa(value,'embedded.fi')
                coder.internal.errorIf(true,'dsp:dsp:private:FilterSystemObjectBase:EmbeddedfiNotSupported');
            end
            validateattributes(value,...
            {'numeric'},{'finite','nonempty','row'},'','Numerator');
            clearMetaData(obj)
            obj.Numerator=value;
        end

        function set.ReflectionCoefficients(obj,value)
            validateattributes(value,...
            {'numeric'},{'finite','nonempty','row'},'','ReflectionCoefficients');
            clearMetaData(obj)
            obj.ReflectionCoefficients=value;
        end

        function set.Structure(obj,val)
            clearMetaData(obj)
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

        function fdhdltool(obj,InputNumericType)























            if~exist('InputNumericType','var')
                error(message('hdlfilter:privgeneratehdl:fdhdltoolinputdatatypenotspecified'));
            end

            errIfNotValidCoeffSource(obj);
            errIfNonZeroInitialConditions(obj);
            firfilt=sysobjHdl(obj,'InputDataType',InputNumericType);
            fdhdltool(firfilt,'InputDataType',InputNumericType);

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
            firfilt=sysobjHdl(obj,varargin{:});


            if isa(firfilt,'dfilt.dfasymfir')
                generatehdl(firfilt,varargin{:});
            else
                generatehdl(firfilt,varargin{:},'FilterSystemObject',clone(obj));
            end
        end

    end

    methods(Hidden)
        function y=supportsUnboundedIO(~)
            y=true;
        end

        function setParameters(obj)

            setFrameStatus(obj,true)

            InputProcessing='Columns as channels (frame based)';

            switch getIndex(obj.StructureSet,obj.Structure)
            case 1
                FilterStructure='Direct form';
            case 2
                FilterStructure='Direct form symmetric';
            case 3
                FilterStructure='Direct form antisymmetric';
            case 4
                FilterStructure='Direct form transposed';
            case 5
                FilterStructure='Lattice MA';
            end

            if getIndex(obj.StructureSet,obj.Structure)~=5

                Coefficients=obj.Numerator;
                coeffValuesFromParam=(getIndex(obj.NumeratorSourceSet,...
                obj.NumeratorSource)==1);

                if(getIndex(obj.CoefficientsDataTypeSet,...
                    obj.CoefficientsDataType)==1)

                    CoefDataTypeStr='Inherit: Same word length as input';

                elseif(coeffValuesFromParam&&...
                    isnumerictype(obj.CustomCoefficientsDataType)&&...
                    strcmpi(obj.CustomCoefficientsDataType.DataTypeMode,...
                    'Fixed-point: unspecified scaling'))

                    CoefDataTypeStr=dsp.internal.createCustomDataTypeProps(...
                    obj.CustomCoefficientsDataType,Coefficients);

                else
                    CoefDataTypeStr=dsp.internal.createCustomDataTypeProps(...
                    obj.CustomCoefficientsDataType);
                end
            else
                Coefficients=obj.ReflectionCoefficients;
                coeffValuesFromParam=(getIndex(obj.ReflectionCoefficientsSourceSet,...
                obj.ReflectionCoefficientsSource)==1);

                if(getIndex(obj.ReflectionCoefficientsDataTypeSet,...
                    obj.ReflectionCoefficientsDataType)==1)

                    CoefDataTypeStr='Inherit: Same word length as input';

                elseif(coeffValuesFromParam&&...
                    isnumerictype(obj.CustomReflectionCoefficientsDataType)&&...
                    strcmpi(obj.CustomReflectionCoefficientsDataType.DataTypeMode,...
                    'Fixed-point: unspecified scaling'))

                    CoefDataTypeStr=dsp.internal.createCustomDataTypeProps(...
                    obj.CustomReflectionCoefficientsDataType,Coefficients);

                else
                    CoefDataTypeStr=dsp.internal.createCustomDataTypeProps(...
                    obj.CustomReflectionCoefficientsDataType);
                end
            end

            if coeffValuesFromParam
                CoefSource='Dialog parameters';
            else
                CoefSource='Input port';
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
            IsCodegenForSim=double(coder.const(dsp.enhancedsim.IsSysObjSimInCodeGen(...
            obj.CoderTarget)));

            obj.compSetParameters({...
            CoefSource,...
            'on',...
            FilterStructure,...
            'Direct form',...
            Coefficients,...
            InputProcessing,...
            'none',...
            'false',...
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
            IsCodegenForSim,...
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
''...
            });
        end
        function restrictionsCell=getFixedPointRestrictions(obj,prop)
            restrictionsCell={};
            switch prop
            case{'CustomProductDataType',...
                'CustomAccumulatorDataType',...
                'CustomOutputDataType',...
                'CustomStateDataType'}
                restrictionsCell={'SPECSIGNED','SCALED'};
            case{'CustomCoefficientsDataType','CustomReflectionCoefficientsDataType'}
                restrictionsCell={'SPECSIGNED'};
            otherwise
                coder.internal.errorIf(true,...
                'dsp:dsp:private:FilterSystemObjectBase:InvalidProperty',prop,class(obj));
            end
        end
        function props=getNonFixedPointProperties(~)
            props=dsp.FIRFilter.getDisplayPropertiesImpl;
        end
        function props=getFixedPointProperties(~)
            props=dsp.FIRFilter.getDisplayFixedPointPropertiesImpl;
        end
        function flag=isPropertyActive(obj,prop)
            flag=~isInactivePropertyImpl(obj,prop);
        end
    end

    methods(Access=protected)

        function validateInputsImpl(obj,varargin)
            if strcmpi(obj.NumeratorSource,'Input port')
                sz=size(varargin{2});
                if sz(1)~=1
                    matlab.system.internal.error(...
                    'MATLAB:system:inputMustBeRowVector','filter coefficients');
                end
            end

            if~isempty(varargin)
                inputData=varargin{1};
                cacheInputDataType(obj,inputData)
            end

            if any(strcmpi({'Direct form symmetric','Direct form antisymmetric'},...
                obj.Structure))&&strcmpi('unsigned',obj.pInputSignedness)
                coder.internal.errorIf(true,'dsp:dsp:private:FilterSystemObjectBase:InputMustBeSignedFIR');
            end

        end

        function y=infoImpl(obj,varargin)
            y=infoFA(obj,varargin{:});
        end

        function flag=isInactivePropertyImpl(obj,prop)

            if getIndex(obj.StructureSet,obj.Structure)~=5

                props={'ReflectionCoefficientsSource','ReflectionCoefficients',...
                'ReflectionCoefficientsDataType','CustomReflectionCoefficientsDataType',...
                'StateDataType','CustomStateDataType'};
                if(strcmp(obj.NumeratorSource,'Property'))
                    if~matlab.system.isSpecifiedTypeMode(obj.CoefficientsDataType)
                        props{end+1}='CustomCoefficientsDataType';
                    end
                else
                    props=[props,{'Numerator','CoefficientsDataType',...
                    'CustomCoefficientsDataType'}];
                end
            else

                props={'NumeratorSource','Numerator',...
                'CoefficientsDataType','CustomCoefficientsDataType'};
                if(strcmp(obj.ReflectionCoefficientsSource,'Property'))
                    if~matlab.system.isSpecifiedTypeMode(obj.ReflectionCoefficientsDataType)
                        props{end+1}='CustomReflectionCoefficientsDataType';
                    end
                else
                    props=[props,{'ReflectionCoefficients',...
                    'ReflectionCoefficientsDataType',...
                    'CustomReflectionCoefficientsDataType'}];
                end
            end

            if obj.FullPrecisionOverride
                props=[props,{'RoundingMethod',...
                'OverflowAction',...
                'ProductDataType',...
                'CustomProductDataType',...
                'AccumulatorDataType',...
                'CustomAccumulatorDataType',...
                'StateDataType',...
                'CustomStateDataType',...
                'OutputDataType',...
                'CustomOutputDataType'}];
            else
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

                isInFullPrecision=...
                strcmpi(obj.ProductDataType,'Full precision')&&...
                strcmpi(obj.AccumulatorDataType,'Full precision')&&...
                strcmpi(obj.OutputDataType,'Same as accumulator');
                if getIndex(obj.StructureSet,obj.Structure)==5
                    isInFullPrecision=isInFullPrecision&&...
                    strcmpi(obj.StateDataType,'Same as accumulator');
                end
                if isInFullPrecision
                    props{end+1}='RoundingMethod';
                    props{end+1}='OverflowAction';
                end
            end
            flag=ismember(prop,props);
        end

        function d=convertToDFILT(obj,arith)



            if strcmp(obj.Structure,'Lattice MA')
                coeffSourcePropName='ReflectionCoefficientsSource';
            else
                coeffSourcePropName='NumeratorSource';
            end
            if~strcmp(obj.(coeffSourcePropName),'Property')
                sendNoAvailableCoefficientsError(obj,coeffSourcePropName);
            end

            dfiltNumPropName='Numerator';
            dfiltFracLenghtPropName='NumFracLength';
            sysObjCoeffPropName='Numerator';
            sysObjCoeffDataTypePropName='Coefficients';

            switch obj.Structure
            case 'Direct form'
                d=dfilt.dffir;
            case 'Direct form symmetric'
                d=dfilt.dfsymfir;
            case 'Direct form antisymmetric'
                d=dfilt.dfasymfir;
            case 'Direct form transposed'
                d=dfilt.dffirt;
            case 'Lattice MA'
                d=dfilt.latticemamin;
                dfiltNumPropName='Lattice';
                dfiltFracLenghtPropName='LatticeFracLength';
                sysObjCoeffPropName='ReflectionCoefficients';
                sysObjCoeffDataTypePropName='ReflectionCoefficients';
            end

            coeffNumericType=[];
            d.Arithmetic=arith;
            d.PersistentMemory=true;

            d.(dfiltNumPropName)=obj.(sysObjCoeffPropName);
            if strcmpi(arith,'fixed')&&...
                strcmp(obj.([sysObjCoeffDataTypePropName,'DataType']),'Custom')
                coeffNumericType=obj.(...
                ['Custom',sysObjCoeffDataTypePropName,'DataType']);
            end

            if strcmpi(arith,'fixed')
                if isempty(coeffNumericType)




                    coeffNumericType=getCoefficientsDataType(obj,'fir',...
                    [sysObjCoeffDataTypePropName,'DataType']);





                    if isLocked(obj)&&strcmpi(obj.pInputSignedness,'Unsigned')
                        coeffNumericType.Signedness='Unsigned';
                    end
                end
                d.CoeffWordLength=coeffNumericType.WordLength;
                if strcmp(coeffNumericType.Signedness,'Unsigned')
                    d.Signed=false;
                end
                if isbinarypointscalingset(coeffNumericType)
                    d.CoeffAutoScale=false;
                    d.(dfiltFracLenghtPropName)=coeffNumericType.FractionLength;
                end



                if(~obj.FullPrecisionOverride||isLocked(obj))&&isprop(d,'FilterInternals')
                    d.FilterInternals='SpecifyPrecision';
                end

                if isLocked(obj)
                    fixedpointinfo=getCompiledFixedPointInfo(obj);

                    if strcmp(obj.Structure,'Lattice MA')==1
                        d.StateWordLength=fixedpointinfo.StateDataType.WordLength;
                        d.StateFracLength=fixedpointinfo.StateDataType.FractionLength;
                        d.AccumMode='SpecifyPrecision';
                        d.ProductMode='SpecifyPrecision';
                        d.OutputMode='SpecifyPrecision';
                    end
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


        function s=saveObjectImpl(obj)
            s=saveObjectImpl@matlab.system.CoreBlockSystem(obj);
            s=saveFA(obj,s);
        end

        function loadObjectImpl(obj,s,wasLocked)
            loadObjectImpl@matlab.system.CoreBlockSystem(obj,s);
            loadFA(obj,s,wasLocked);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='dsparch4/Discrete FIR Filter';
        end

        function b=generatesCode
            b=true;
        end
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end

    methods(Static)
        function helpFixedPoint






            matlab.system.dispFixptHelp('dsp.FIRFilter',dsp.FIRFilter.getDisplayFixedPointPropertiesImpl);
        end
    end

    methods(Access=protected)
        function setPortDataTypeConnections(obj)
            setPortDataTypeConnection(obj,1,1);
        end
    end

    methods(Static,Hidden)

        function props=getDisplayPropertiesImpl()
            props={...
            'Structure',...
            'NumeratorSource',...
            'ReflectionCoefficientsSource',...
            'Numerator',...
            'ReflectionCoefficients',...
            'InitialConditions'};
        end

        function props=getDisplayFixedPointPropertiesImpl()
            props={...
            'FullPrecisionOverride','RoundingMethod','OverflowAction',...
            'CoefficientsDataType','CustomCoefficientsDataType',...
            'ReflectionCoefficientsDataType','CustomReflectionCoefficientsDataType',...
            'ProductDataType','CustomProductDataType',...
            'AccumulatorDataType','CustomAccumulatorDataType',...
            'StateDataType','CustomStateDataType',...
            'OutputDataType','CustomOutputDataType'};
        end



        function tunePropsMap=getTunablePropertiesMap()
            tunePropsMap.Numerator=4;







        end
    end

    methods(Hidden,Sealed)
        function s=getCompiledFixedPointInfo(obj)
            if strcmpi(obj.Structure,'Lattice MA')
                props={'ReflectionCoefficientsDataType','ProductDataType',...
                'AccumulatorDataType','StateDataType','OutputDataType'};
                coreBlkParamNames={'CoefDataTypeName','ProductDataTypeName',...
                'AccumDataTypeName','StateDataTypeName','OutDataTypeName'};
            else
                props={'CoefficientsDataType','ProductDataType',...
                'AccumulatorDataType','OutputDataType'};
                coreBlkParamNames={'CoefDataTypeName','ProductDataTypeName',...
                'AccumDataTypeName','OutDataTypeName'};
            end
            sTmp=getCompiledFixedPointInfo@matlab.system.CoreBlockSystem(obj,coreBlkParamNames);
            s=struct;
            for idx=1:length(props)
                s.(props{idx})=sTmp.(coreBlkParamNames{idx});
            end
        end
    end
end
function errIfNotValidCoeffSource(obj)
    if strcmp(obj.NumeratorSource,'Input port')
        error(message('dsp:dsp:private:FilterSystemObjectBase:HDLFIRInputPortError'));
    end
end

function errIfNonZeroInitialConditions(obj)

    if~all(obj.InitialConditions==0)
        error(message('dsp:dsp:private:FilterSystemObjectBase:HDLNonZeroICError'));
    end
end

classdef(Hidden)VarianceBase<matlab.system.SFunSystem






%#function mdspstatfcns

%#codegen
%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)




        ResetCondition='Non-zero';






        CustomDimension=1;




        ROIForm='Rectangles';




        ROIPortion='Entire ROI';




        ROIStatistics='Individual statistics for each ROI';






        RoundingMethod='Floor';


        OverflowAction='Wrap';




        InputSquaredProductDataType='Same as input';








        CustomInputSquaredProductDataType=numerictype([],32,15);




        InputSumSquaredProductDataType='Same as input-squared product';








        CustomInputSumSquaredProductDataType=numerictype([],32,23);



        AccumulatorDataType='Same as input-squared product';







        CustomAccumulatorDataType=numerictype([],32,0);



        OutputDataType='Same as input-squared product';







        CustomOutputDataType=numerictype([],16,0);





        RunningVariance(1,1)logical=false;







        ResetInputPort(1,1)logical=false;








        ROIProcessing(1,1)logical=false;








        ValidityOutputPort(1,1)logical=false;
    end

    properties(Abstract,Nontunable)
        Dimension;
    end

    properties(Constant,Hidden)
        ResetConditionSet=dsp.CommonSets.getSet('ResetCondition');
        ROIFormSet=dsp.CommonSets.getSet('ROIForm');
        ROIPortionSet=dsp.CommonSets.getSet('ROIPortionToProcess');
        ROIStatisticsSet=dsp.CommonSets.getSet('ROIStatistics');

        RoundingMethodSet=dsp.CommonSets.getSet('RoundingMethod');
        OverflowActionSet=dsp.CommonSets.getSet('OverflowAction');
        InputSquaredProductDataTypeSet=dsp.CommonSets.getSet('FixptModeBasic');
        InputSumSquaredProductDataTypeSet=matlab.system.StringSet({...
        'Same as input-squared product',...
        matlab.system.getSpecifyString('scaled')});
        AccumulatorDataTypeSet=matlab.system.StringSet({...
        'Same as input-squared product',...
        'Same as input',...
        matlab.system.getSpecifyString('scaled')});
        OutputDataTypeSet=matlab.system.StringSet({...
        'Same as input-squared product',...
        'Same as input',...
        matlab.system.getSpecifyString('scaled')});
    end

    methods

        function obj=VarianceBase(varargin)
            if strcmp(varargin{end},'XYcoord')
                s_fcn='mvipstatfcns';
            else
                s_fcn='mdspstatfcns';
            end
            obj@matlab.system.SFunSystem(s_fcn);
            args=varargin(1:end-1);
            setProperties(obj,nargin-1,args{:});
        end

        function set.CustomInputSquaredProductDataType(obj,val)
            validateCustomDataType(obj,'CustomInputSquaredProductDataType',val,...
            {'AUTOSIGNED','SCALED'});
            obj.CustomInputSquaredProductDataType=val;
        end

        function set.CustomInputSumSquaredProductDataType(obj,val)
            validateCustomDataType(obj,'CustomInputSumSquaredProductDataType',val,...
            {'AUTOSIGNED','SCALED'});
            obj.CustomInputSumSquaredProductDataType=val;
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

    methods(Access=protected)
        function flag=isFrameBasedProcessing(~)
            flag=false;
        end
    end

    methods(Hidden)
        function setParameters(obj)

            fcn=0;

            if obj.RunningVariance
                setVarSizeAllowedStatus(obj,false);
            else
                setVarSizeAllowedStatus(obj,true);
            end

            if obj.ResetInputPort
                ResetConditionIdx=getIndex(...
                obj.ResetConditionSet,obj.ResetCondition);
            else
                ResetConditionIdx=0;
            end
            DimensionIdx=getIndex(...
            obj.DimensionSet,obj.Dimension);
            ROIFormIdx=getIndex(...
            obj.ROIFormSet,obj.ROIForm);
            ROIPortionIdx=getIndex(...
            obj.ROIPortionSet,obj.ROIPortion);
            ROIStatisticsIdx=getIndex(...
            obj.ROIStatisticsSet,obj.ROIStatistics);

            dtInfo=getFixptDataTypeInfo(obj,{...
            'InputSquaredProduct','InputSumSquaredProduct','Accumulator','Output'});
            InputProcessing=~obj.isFrameBasedProcessing+1;

            obj.compSetParameters({...
            fcn,...
            double(obj.RunningVariance),...
            ResetConditionIdx,...
            InputProcessing,...
            DimensionIdx,...
            obj.CustomDimension,...
            double(obj.ROIProcessing),...
            ROIFormIdx,...
            ROIPortionIdx,...
            ROIStatisticsIdx,...
            double(obj.ValidityOutputPort),...
            [],[],...
            dtInfo.InputSquaredProductDataType,...
            dtInfo.InputSquaredProductWordLength,...
            dtInfo.InputSquaredProductFracLength,...
            dtInfo.AccumulatorDataType,...
            dtInfo.AccumulatorWordLength,...
            dtInfo.AccumulatorFracLength,...
            dtInfo.InputSumSquaredProductDataType,...
            dtInfo.InputSumSquaredProductWordLength,...
            dtInfo.InputSumSquaredProductFracLength,...
            dtInfo.OutputDataType,...
            dtInfo.OutputWordLength,...
            dtInfo.OutputFracLength,...
            dtInfo.RoundingMethod,...
            dtInfo.OverflowAction...
            });
        end
    end

    methods(Access=protected)
        function flag=isInactivePropertyImpl(obj,prop)

            if isempty(obj.ResetCondition)
                return;
            end


            flag=false;
            switch prop
            case 'Dimension'
                if obj.RunningVariance
                    flag=true;
                end
            case 'CustomDimension'
                if obj.RunningVariance||...
                    strcmp(obj.Dimension,'Column')||...
                    strcmp(obj.Dimension,'Row')||...
                    strcmp(obj.Dimension,'All')
                    flag=true;
                end
            case 'ROIProcessing'
                if obj.RunningVariance||...
                    strcmp(obj.Dimension,'Custom')||...
                    strcmp(obj.Dimension,'Column')||...
                    strcmp(obj.Dimension,'Row')
                    flag=true;
                end
            case 'ROIForm'
                if obj.RunningVariance||...
                    strcmp(obj.Dimension,'Custom')||...
                    strcmp(obj.Dimension,'Column')||...
                    strcmp(obj.Dimension,'Row')||...
                    (strcmp(obj.Dimension,'All')&&...
                    ~obj.ROIProcessing)
                    flag=true;
                end
            case 'ROIPortion'
                if obj.RunningVariance||...
                    strcmp(obj.Dimension,'Custom')||...
                    strcmp(obj.Dimension,'Column')||...
                    strcmp(obj.Dimension,'Row')||...
                    (strcmp(obj.Dimension,'All')&&...
                    (~obj.ROIProcessing||...
                    strcmp(obj.ROIForm,'Binary mask')||...
                    strcmp(obj.ROIForm,'Lines')||...
                    strcmp(obj.ROIForm,'Label matrix')))
                    flag=true;
                end
            case{'ROIStatistics','ValidityOutputPort'}
                if obj.RunningVariance||...
                    strcmp(obj.Dimension,'Custom')||...
                    strcmp(obj.Dimension,'Column')||...
                    strcmp(obj.Dimension,'Row')||...
                    (strcmp(obj.Dimension,'All')&&...
                    (~obj.ROIProcessing||...
                    strcmp(obj.ROIForm,'Binary mask')))
                    flag=true;
                end
            case 'ResetCondition'
                if~obj.RunningVariance||...
                    ~obj.ResetInputPort
                    flag=true;
                end
            case 'ResetInputPort'
                if~obj.RunningVariance
                    flag=true;
                end
            case 'CustomInputSquaredProductDataType'
                if~matlab.system.isSpecifiedTypeMode(obj.InputSquaredProductDataType)
                    flag=true;
                end
            case 'CustomInputSumSquaredProductDataType'
                if~matlab.system.isSpecifiedTypeMode(obj.InputSumSquaredProductDataType)
                    flag=true;
                end
            case 'CustomAccumulatorDataType'
                if~matlab.system.isSpecifiedTypeMode(obj.AccumulatorDataType)
                    flag=true;
                end
            case 'CustomOutputDataType'
                if~matlab.system.isSpecifiedTypeMode(obj.OutputDataType)
                    flag=true;
                end
            end
        end

        function loadObjectImpl(obj,s,~)
            loadObjectImpl@matlab.system.SFunSystem(obj,s);
        end
    end

    methods(Static,Hidden)
        function props=getDisplayPropertiesImpl()
            props={...
'RunningVariance'...
            ,'ResetInputPort'...
            ,'ResetCondition'...
            ,'Dimension'...
            ,'CustomDimension'...
            ,'ROIProcessing'...
            ,'ROIForm'...
            ,'ROIPortion'...
            ,'ROIStatistics'...
            ,'ValidityOutputPort'...
            };
        end
        function props=getDisplayFixedPointPropertiesImpl()
            props={...
            'RoundingMethod','OverflowAction'...
            ,'InputSquaredProductDataType','CustomInputSquaredProductDataType'...
            ,'InputSumSquaredProductDataType','CustomInputSumSquaredProductDataType'...
            ,'AccumulatorDataType','CustomAccumulatorDataType'...
            ,'OutputDataType','CustomOutputDataType'...
            };
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

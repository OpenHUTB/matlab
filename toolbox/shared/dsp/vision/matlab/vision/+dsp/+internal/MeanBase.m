classdef(Hidden)MeanBase<matlab.system.SFunSystem






%#function mdspstatfcns

%#codegen
%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)





        ResetCondition='Non-zero'






        CustomDimension=1;







        ROIForm='Rectangles';




        ROIPortion='Entire ROI';




        ROIStatistics='Individual statistics for each ROI';






        RoundingMethod='Floor';


        OverflowAction='Wrap';



        AccumulatorDataType='Same as input';







        CustomAccumulatorDataType=numerictype([],32,30);



        OutputDataType='Same as accumulator';







        CustomOutputDataType=numerictype([],32,30);






        RunningMean(1,1)logical=false;






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
        AccumulatorDataTypeSet=dsp.CommonSets.getSet('FixptModeBasic');
        OutputDataTypeSet=dsp.CommonSets.getSet('FixptModeAccum');
    end

    methods
        function obj=MeanBase(varargin)
            if strcmp(varargin{end},'XYcoord')
                s_fcn='mvipstatfcns';
            else
                s_fcn='mdspstatfcns';
            end
            obj@matlab.system.SFunSystem(s_fcn);
            args=varargin(1:end-1);
            setProperties(obj,nargin-1,args{:});
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

            if obj.RunningMean
                setVarSizeAllowedStatus(obj,false);
            else
                setVarSizeAllowedStatus(obj,true);
            end

            if obj.RunningMean&&obj.ResetInputPort
                ResetRunningMeanIdx=getIndex(...
                obj.ResetConditionSet,obj.ResetCondition);
            else
                ResetRunningMeanIdx=0;
            end

            DimensionIdx=getIndex(...
            obj.DimensionSet,obj.Dimension);


            ROIFormIdx=getIndex(obj.ROIFormSet,obj.ROIForm);
            ROIPortionIdx=getIndex(...
            obj.ROIPortionSet,obj.ROIPortion);
            ROIStatisticsIdx=getIndex(...
            obj.ROIStatisticsSet,obj.ROIStatistics);
            InputProcessing=~obj.isFrameBasedProcessing+1;


            fcn=3;

            if isSizesOnlyCall(obj)
                obj.compSetParameters({...
                fcn,...
                double(obj.RunningMean),...
                ResetRunningMeanIdx,...
                InputProcessing,...
                DimensionIdx,...
                obj.CustomDimension,...
                double(obj.ROIProcessing),...
                ROIFormIdx,...
                ROIPortionIdx,...
                ROIStatisticsIdx,...
                double(obj.ValidityOutputPort),...
                [],[],...
                0,...
                16,...
                0,...
                2,...
                2,...
                2,...
                0,...
                2,...
                0,...
                2,...
                2,...
                2,...
                2,...
                1,...
                });
            else
                dtInfo=getFixptDataTypeInfo(obj,{'Accumulator','Output'});

                obj.compSetParameters({...
                fcn,...
                double(obj.RunningMean),...
                ResetRunningMeanIdx,...
                InputProcessing,...
                DimensionIdx,...
                obj.CustomDimension,...
                double(obj.ROIProcessing),...
                ROIFormIdx,...
                ROIPortionIdx,...
                ROIStatisticsIdx,...
                double(obj.ValidityOutputPort),...
                [],[],...
                0,...
                16,...
                0,...
                dtInfo.AccumulatorDataType,...
                dtInfo.AccumulatorWordLength,...
                dtInfo.AccumulatorFracLength,...
                0,...
                2,...
                0,...
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

            if isempty(obj.ResetCondition)
                return;
            end

            flag=false;
            switch prop
            case 'Dimension'
                if obj.RunningMean
                    flag=true;
                end
            case 'CustomDimension'
                if obj.RunningMean||...
                    strcmp(obj.Dimension,'Column')||...
                    strcmp(obj.Dimension,'Row')||...
                    strcmp(obj.Dimension,'All')
                    flag=true;
                end
            case 'ROIProcessing'
                if obj.RunningMean||...
                    strcmp(obj.Dimension,'Custom')||...
                    strcmp(obj.Dimension,'Column')||...
                    strcmp(obj.Dimension,'Row')
                    flag=true;
                end
            case 'ROIForm'
                if obj.RunningMean||...
                    strcmp(obj.Dimension,'Custom')||...
                    strcmp(obj.Dimension,'Column')||...
                    strcmp(obj.Dimension,'Row')||...
                    (strcmp(obj.Dimension,'All')&&...
                    ~obj.ROIProcessing)
                    flag=true;
                end
            case 'ROIPortion'
                if obj.RunningMean||...
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
                if obj.RunningMean||...
                    strcmp(obj.Dimension,'Custom')||...
                    strcmp(obj.Dimension,'Column')||...
                    strcmp(obj.Dimension,'Row')||...
                    (strcmp(obj.Dimension,'All')&&...
                    (~obj.ROIProcessing||...
                    strcmp(obj.ROIForm,'Binary mask')))
                    flag=true;
                end
            case 'ResetCondition'
                if~obj.RunningMean||...
                    ~obj.ResetInputPort
                    flag=true;
                end
            case 'ResetInputPort'
                if~obj.RunningMean
                    flag=true;
                end
            case 'CustomOutputDataType'
                if~matlab.system.isSpecifiedTypeMode(obj.OutputDataType)
                    flag=true;
                end
            case 'CustomAccumulatorDataType'
                if~matlab.system.isSpecifiedTypeMode(obj.AccumulatorDataType)
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
'RunningMean'...
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

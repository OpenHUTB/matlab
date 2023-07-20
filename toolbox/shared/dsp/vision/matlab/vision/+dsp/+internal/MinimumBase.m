classdef(Hidden)MinimumBase<matlab.system.SFunSystem






%#function mdspstatminmax

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



        ProductDataType='Same as input';







        CustomProductDataType=numerictype([],32,30);



        AccumulatorDataType='Same as product';







        CustomAccumulatorDataType=numerictype([],32,30);





        ValueOutputPort(1,1)logical=true;





        RunningMinimum(1,1)logical=false;





        IndexOutputPort(1,1)logical=true;






        ResetInputPort(1,1)logical=false;








        ROIProcessing(1,1)logical=false;








        ValidityOutputPort(1,1)logical=false;
    end

    properties(Abstract,Nontunable)
        IndexBase;
        Dimension;
    end

    properties(Constant,Hidden)
        ResetConditionSet=dsp.CommonSets.getSet('ResetCondition');
        ROIFormSet=dsp.CommonSets.getSet('ROIForm');
        ROIPortionSet=dsp.CommonSets.getSet('ROIPortionToProcess');
        ROIStatisticsSet=dsp.CommonSets.getSet('ROIStatistics');

        RoundingMethodSet=dsp.CommonSets.getSet('RoundingMethod');
        OverflowActionSet=dsp.CommonSets.getSet('OverflowAction');
        ProductDataTypeSet=dsp.CommonSets.getSet('FixptModeBasic');
        AccumulatorDataTypeSet=dsp.CommonSets.getSet(...
        'FixptModeProd');
    end

    properties(Access=private)
        pRCcoord;
    end
    methods
        function obj=MinimumBase(varargin)
            rcCoord=true;
            if strcmp(varargin{end},'XYcoord')
                s_fcn='mvipstatminmax';
                rcCoord=false;
            else
                s_fcn='mdspstatminmax';
            end
            obj@matlab.system.SFunSystem(s_fcn);
            args=varargin(1:end-1);
            setProperties(obj,nargin-1,args{:});
            obj.pRCcoord=rcCoord;
        end

        function set.CustomProductDataType(obj,val)
            validateCustomDataType(obj,'CustomProductDataType',val,...
            {'AUTOSIGNED','SCALED'});
            obj.CustomProductDataType=val;
        end

        function set.CustomAccumulatorDataType(obj,val)
            validateCustomDataType(obj,'CustomAccumulatorDataType',val,...
            {'AUTOSIGNED','SCALED'});
            obj.CustomAccumulatorDataType=val;
        end
    end

    methods(Access=protected)
        function flag=isFrameBasedProcessing(~)
            flag=false;
        end
    end

    methods(Hidden)
        function setParameters(obj)

            OutputFormIdx=4;
            if(obj.RunningMinimum)
                setVarSizeAllowedStatus(obj,false);

            else
                setVarSizeAllowedStatus(obj,true);
                coder.internal.assert(obj.ValueOutputPort||obj.IndexOutputPort,...
                'dspshared:system:Minimum:incorrectOutputsSpecified');
                if obj.ValueOutputPort
                    OutputFormIdx=OutputFormIdx-2;
                end
                if obj.IndexOutputPort
                    OutputFormIdx=OutputFormIdx-1;
                end
            end

            if obj.RunningMinimum&&obj.ResetInputPort
                ResetRunningMinimumIdx=getIndex(...
                obj.ResetConditionSet,obj.ResetCondition);
            else
                ResetRunningMinimumIdx=0;
            end


            IndexBaseIdx=getIndex(obj.IndexBaseSet,obj.IndexBase);
            DimensionIdx=getIndex(obj.DimensionSet,obj.Dimension);
            ROIFormIdx=getIndex(obj.ROIFormSet,obj.ROIForm);
            ROIPortionIdx=getIndex(...
            obj.ROIPortionSet,obj.ROIPortion);
            ROIStatisticsIdx=getIndex(...
            obj.ROIStatisticsSet,obj.ROIStatistics);


            statfcn=4;
            map=[0,2,3,1];
            OutputFormIdx=map(OutputFormIdx);
            map=[1,0];
            IndexBaseIdx=map(IndexBaseIdx);
            if(~obj.pRCcoord)
                IndexBaseIdx=0;
            end
            map=[2,0,1,3];
            DimensionIdx=map(DimensionIdx);
            InputProcessing=~obj.isFrameBasedProcessing+1;

            if isSizesOnlyCall(obj)
                obj.compSetParameters({...
                statfcn,...
                OutputFormIdx,...
                ResetRunningMinimumIdx,...
                InputProcessing,...
                DimensionIdx,...
                IndexBaseIdx,...
                obj.CustomDimension,...
                double(obj.ROIProcessing),...
                ROIFormIdx,...
                ROIPortionIdx,...
                ROIStatisticsIdx,...
                double(obj.ValidityOutputPort),...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
                1,...
                });

            else
                dtInfo=getFixptDataTypeInfo(obj,...
                {'Product','Accumulator'});
                obj.compSetParameters({...
                statfcn,...
                OutputFormIdx,...
                ResetRunningMinimumIdx,...
                InputProcessing,...
                DimensionIdx,...
                IndexBaseIdx,...
                obj.CustomDimension,...
                double(obj.ROIProcessing),...
                ROIFormIdx,...
                ROIPortionIdx,...
                ROIStatisticsIdx,...
                double(obj.ValidityOutputPort),...
                dtInfo.ProductDataType,...
                dtInfo.ProductWordLength,...
                dtInfo.ProductFracLength,...
                dtInfo.AccumulatorDataType,...
                dtInfo.AccumulatorWordLength,...
                dtInfo.AccumulatorFracLength,...
                dtInfo.RoundingMethod,...
                dtInfo.OverflowAction...
                });
            end
        end
    end

    methods(Access=protected)
        function flag=isInactivePropertyImpl(obj,prop)

            flag=false;
            if isempty(obj.ResetCondition)
                return;
            end
            switch prop
            case{'IndexOutputPort','Dimension','ValueOutputPort'}
                if obj.RunningMinimum
                    flag=true;
                end
            case 'CustomDimension'
                if obj.RunningMinimum||...
                    strcmp(obj.Dimension,'Column')||...
                    strcmp(obj.Dimension,'Row')||...
                    strcmp(obj.Dimension,'All')
                    flag=true;
                end
            case 'IndexBase'
                if obj.RunningMinimum||...
                    ~obj.IndexOutputPort||...
                    ~obj.pRCcoord
                    flag=true;
                end
            case 'ROIProcessing'
                if obj.RunningMinimum||...
                    strcmp(obj.Dimension,'Custom')||...
                    strcmp(obj.Dimension,'Column')||...
                    strcmp(obj.Dimension,'Row')
                    flag=true;
                end
            case 'ROIForm'
                if obj.RunningMinimum||...
                    strcmp(obj.Dimension,'Custom')||...
                    strcmp(obj.Dimension,'Column')||...
                    strcmp(obj.Dimension,'Row')||...
                    (strcmp(obj.Dimension,'All')&&...
                    ~obj.ROIProcessing)
                    flag=true;
                end
            case 'ROIPortion'
                if obj.RunningMinimum||...
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
                if obj.RunningMinimum||...
                    strcmp(obj.Dimension,'Custom')||...
                    strcmp(obj.Dimension,'Column')||...
                    strcmp(obj.Dimension,'Row')||...
                    (strcmp(obj.Dimension,'All')&&...
                    (~obj.ROIProcessing||...
                    strcmp(obj.ROIForm,'Binary mask')))
                    flag=true;
                end
            case 'ResetCondition'
                if~obj.RunningMinimum||...
                    ~obj.ResetInputPort
                    flag=true;
                end
            case 'ResetInputPort'
                if~obj.RunningMinimum
                    flag=true;
                end
            case 'CustomProductDataType'
                if~matlab.system.isSpecifiedTypeMode(obj.ProductDataType)
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
            'ValueOutputPort',...
            'RunningMinimum',...
            'IndexOutputPort',...
            'ResetInputPort',...
            'ResetCondition',...
            'IndexBase',...
            'Dimension',...
            'CustomDimension',...
            'ROIProcessing',...
            'ROIForm',...
            'ROIPortion',...
            'ROIStatistics',...
'ValidityOutputPort'...
            };
        end

        function props=getDisplayFixedPointPropertiesImpl()
            props={...
            'RoundingMethod','OverflowAction'...
            ,'ProductDataType','CustomProductDataType'...
            ,'AccumulatorDataType','CustomAccumulatorDataType'...
            };
        end
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end

    methods(Access=protected)
        function setPortDataTypeConnections(obj)


            portNum=1;
            if(obj.ValueOutputPort||obj.RunningMinimum)
                setPortDataTypeConnection(obj,1,portNum);
                portNum=portNum+1;
            end
            if~obj.RunningMinimum&&...
                (obj.IndexOutputPort)&&...
                isInputFloatingPoint(obj,1)
                setPortDataTypeConnection(obj,1,portNum);
            end
        end
    end
end



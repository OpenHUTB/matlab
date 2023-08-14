classdef(Hidden)StandardDeviationBase<matlab.system.SFunSystem






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





        RunningStandardDeviation(1,1)logical=false;







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
    end

    methods

        function obj=StandardDeviationBase(varargin)
            if strcmp(varargin{end},'XYcoord')
                s_fcn='mvipstatfcns';
            else
                s_fcn='mdspstatfcns';
            end
            obj@matlab.system.SFunSystem(s_fcn);
            args=varargin(1:end-1);
            setProperties(obj,nargin-1,args{:});
        end
    end

    methods(Access=protected)
        function flag=isFrameBasedProcessing(~)
            flag=false;
        end
    end

    methods(Hidden)
        function setParameters(obj)

            if obj.RunningStandardDeviation
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
            DimensionIdx=getIndex(obj.DimensionSet,obj.Dimension);
            RoiType=getIndex(obj.ROIFormSet,obj.ROIForm);
            RoiPortion=getIndex(...
            obj.ROIPortionSet,obj.ROIPortion);
            RoiOutput=getIndex(obj.ROIStatisticsSet,obj.ROIStatistics);
            fcn=1;
            InputProcessing=~obj.isFrameBasedProcessing+1;

            obj.compSetParameters({...
            fcn,...
            double(obj.RunningStandardDeviation),...
            ResetConditionIdx,...
            InputProcessing,...
            DimensionIdx,...
            obj.CustomDimension,...
            double(obj.ROIProcessing),...
            RoiType,...
            RoiPortion,...
            RoiOutput,...
            double(obj.ValidityOutputPort)...
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
                if obj.RunningStandardDeviation
                    flag=true;
                end
            case 'CustomDimension'
                if obj.RunningStandardDeviation||...
                    strcmp(obj.Dimension,'Column')||...
                    strcmp(obj.Dimension,'Row')||...
                    strcmp(obj.Dimension,'All')
                    flag=true;
                end
            case 'ROIProcessing'
                if obj.RunningStandardDeviation||...
                    strcmp(obj.Dimension,'Custom')||...
                    strcmp(obj.Dimension,'Column')||...
                    strcmp(obj.Dimension,'Row')
                    flag=true;
                end
            case 'ROIForm'
                if obj.RunningStandardDeviation||...
                    strcmp(obj.Dimension,'Custom')||...
                    strcmp(obj.Dimension,'Column')||...
                    strcmp(obj.Dimension,'Row')||...
                    (strcmp(obj.Dimension,'All')&&...
                    ~obj.ROIProcessing)
                    flag=true;
                end
            case 'ROIPortion'
                if obj.RunningStandardDeviation||...
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
                if obj.RunningStandardDeviation||...
                    strcmp(obj.Dimension,'Custom')||...
                    strcmp(obj.Dimension,'Column')||...
                    strcmp(obj.Dimension,'Row')||...
                    (strcmp(obj.Dimension,'All')&&...
                    (~obj.ROIProcessing||...
                    strcmp(obj.ROIForm,'Binary mask')))
                    flag=true;
                end
            case 'ResetCondition'
                if~obj.RunningStandardDeviation||...
                    ~obj.ResetInputPort
                    flag=true;
                end
            case 'ResetInputPort'
                if~obj.RunningStandardDeviation
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
'RunningStandardDeviation'...
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

classdef RMS<matlab.system.SFunSystem





%#function mdspstatfcns

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)





        ResetCondition='Non-zero'





        Dimension='Column';






        CustomDimension=1;





        RunningRMS(1,1)logical=false;






        ResetInputPort(1,1)logical=false;
    end


    properties(Constant,Hidden)
        ResetConditionSet=dsp.CommonSets.getSet('ResetCondition');
        DimensionSet=dsp.CommonSets.getSet('Dimension');
    end

    methods

        function obj=RMS(varargin)
            obj@matlab.system.SFunSystem('mdspstatfcns');
            setProperties(obj,nargin,varargin{:});
            setFrameStatus(obj,true);
        end
    end

    methods(Hidden)
        function setParameters(obj)


            if obj.RunningRMS
                setVarSizeAllowedStatus(obj,false);
            else
                setVarSizeAllowedStatus(obj,true);
            end

            ResetConditionIdx=getIndex(...
            obj.ResetConditionSet,obj.ResetCondition);
            DimensionIdx=getIndex(...
            obj.DimensionSet,obj.Dimension);
            if(obj.ResetInputPort)
                ResetRunningRMSIdx=ResetConditionIdx;
            else
                ResetRunningRMSIdx=0;
            end
            InputProcessing=1;

            fcn=2;

            obj.compSetParameters({...
            fcn,...
            double(obj.RunningRMS),...
            ResetRunningRMSIdx,...
            InputProcessing,...
            DimensionIdx,...
            obj.CustomDimension,...
            });
        end
    end

    methods(Access=protected)

        function flag=isInactivePropertyImpl(obj,prop)
            flag=false;
            switch prop
            case 'Dimension'
                if obj.RunningRMS
                    flag=true;
                end
            case 'CustomDimension'
                if obj.RunningRMS||...
                    ~strcmpi(obj.Dimension,'Custom')
                    flag=true;
                end
            case 'ResetCondition'
                if~obj.RunningRMS||...
                    ~obj.ResetInputPort
                    flag=true;
                end
            case{'ResetInputPort'}
                if~obj.RunningRMS
                    flag=true;
                end
            end
        end

        function loadObjectImpl(obj,s,~)
            loadObjectImpl@matlab.system.SFunSystem(obj,s);
        end

    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='dspstat3/RMS';
        end

        function props=getDisplayPropertiesImpl()
            props={...
'RunningRMS'...
            ,'ResetInputPort'...
            ,'ResetCondition'...
            ,'Dimension'...
            ,'CustomDimension'...
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


classdef BlockLMSFilter<matlab.system.SFunSystem































































































%#function mdspblms

    properties





        StepSize=0.1;






        LeakageFactor=1.0;
    end

    properties(Nontunable)



        Length=32;





        BlockSize=32;



        StepSizeSource='Property';




        InitialWeights=0;







        WeightsResetCondition='Non-zero';









        AdaptInputPort(1,1)logical=false;









        WeightsResetInputPort(1,1)logical=false;



        WeightsOutputPort(1,1)logical=true;
    end

    properties(Constant,Hidden)
        StepSizeSourceSet=dsp.CommonSets.getSet(...
        'PropertyOrInputPort');
        WeightsResetConditionSet=dsp.CommonSets.getSet(...
        'ResetCondition');
    end

    methods
        function obj=BlockLMSFilter(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mdspblms');
            setProperties(obj,nargin,varargin{:},'Length','BlockSize');
            setVarSizeAllowedStatus(obj,false);
        end

        function[mumax,mumaxmse]=maxstep(obj,x)













            [mumax,mumaxmse]=dsp.internal.maxstep(obj,x);
        end

        function[mse,meanW,W,traceK]=msesim(obj,varargin)

































            [mse,meanW,W,traceK]=dsp.internal.msesim(obj,varargin{:});
        end
    end

    methods(Hidden)
        function setParameters(obj)
            StepSizeSourceIdx=getIndex(...
            obj.StepSizeSourceSet,obj.StepSizeSource);
            AdaptWeightsIdx=double(obj.AdaptInputPort);

            if obj.WeightsResetInputPort
                ResetWeightsIdx=getIndex(obj.WeightsResetConditionSet,...
                obj.WeightsResetCondition);
            else
                ResetWeightsIdx=0;
            end

            obj.compSetParameters({...
            obj.Length,...
            obj.BlockSize,...
            StepSizeSourceIdx,...
            obj.StepSize,...
            obj.LeakageFactor,...
            1,...
            obj.InitialWeights,...
            AdaptWeightsIdx,...
            ResetWeightsIdx,...
            double(obj.WeightsOutputPort)...
            });
        end
    end

    methods(Access=protected)
        function flag=isInactivePropertyImpl(obj,prop)
            flag=false;
            if strcmp(prop,'WeightsResetCondition')&&~obj.WeightsResetInputPort
                flag=true;
            elseif strcmp(prop,'StepSize')&&~strcmp(obj.StepSizeSource,'Property')
                flag=true;
            end
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='dspadpt3/Block LMS Filter';
        end


        function props=getDisplayPropertiesImpl()
            props={...
'Length'...
            ,'BlockSize'...
            ,'StepSizeSource'...
            ,'StepSize'...
            ,'LeakageFactor'...
            ,'InitialWeights'...
            ,'AdaptInputPort'...
            ,'WeightsResetInputPort'...
            ,'WeightsResetCondition',...
'WeightsOutputPort'...
            };
        end



        function props=getValueOnlyProperties()
            props={'Length','BlockSize'};
        end




        function tunePropsMap=getTunablePropertiesMap()
            tunePropsMap.StepSize=3;
            tunePropsMap.LeakageFactor=4;
        end

        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end

    methods(Access=protected)
        function setPortDataTypeConnections(obj)
            setPortDataTypeConnection(obj,1,1);
            setPortDataTypeConnection(obj,1,2);
            if getNumOutputs(obj)>2
                setPortDataTypeConnection(obj,1,3);
            end
        end
    end

end

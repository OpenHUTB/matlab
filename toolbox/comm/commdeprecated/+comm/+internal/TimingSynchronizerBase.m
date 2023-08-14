classdef TimingSynchronizerBase<matlab.system.SFunSystem




%#ok<*EMCLS>
%#ok<*EMCA>

    properties





        ErrorUpdateGain=0.05;
    end

    properties(Nontunable)



        SamplesPerSymbol=4;









        ResetCondition='Never';








        ResetInputPort(1,1)logical=false;
    end

    properties(Constant,Hidden)
        ResetConditionSet=comm.CommonSets.getSet('ResetOptions');
    end

    methods

        function obj=TimingSynchronizerBase(mfun)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem(mfun);
            setVarSizeAllowedStatus(obj,false);
        end
    end

    properties(Access=protected,Nontunable)
pSynchronizerIndex
    end

    methods(Hidden)
        function setParameters(obj)
            resetIdx=getIndex(obj.ResetConditionSet,obj.ResetCondition);
            if obj.ResetInputPort
                resetBlockIdx=3;
            else
                resetBlockIdx=resetIdx;
            end


            obj.compSetParameters({...
            obj.SamplesPerSymbol,...
            obj.ErrorUpdateGain,...
            resetBlockIdx,...
            obj.pSynchronizerIndex});
        end
    end

    methods(Access=protected)
        function flag=isInactivePropertyImpl(obj,prop)
            props={};
            if obj.ResetInputPort
                props{1}='ResetCondition';
            end
            flag=ismember(prop,props);
        end

        function setPortDataTypeConnections(obj)
            setPortDataTypeConnection(obj,1,1);
            setPortDataTypeConnection(obj,1,2);
        end
    end

    methods(Static,Hidden)
        function props=getDisplayPropertiesImpl()
            props={...
            'SamplesPerSymbol',...
            'ErrorUpdateGain',...
            'ResetInputPort',...
            'ResetCondition'};
        end



        function tunePropsMap=getTunablePropertiesMap()
            tunePropsMap.ErrorUpdateGain=1;
        end
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end

end


classdef PhaseFrequencyOffset<matlab.system.SFunSystem








































































%#function mcomfreqoffset

%#ok<*EMCLS>
%#ok<*EMCA>

    properties














        PhaseOffset=0;

















        FrequencyOffset=0;
    end

    properties(Nontunable)






        FrequencyOffsetSource='Property';



        SampleRate=1;
    end

    properties(Constant,Hidden)
        FrequencyOffsetSourceSet=comm.CommonSets.getSet('SpecifyInputs');
    end

    methods
        function obj=PhaseFrequencyOffset(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mcomfreqoffset');
            setProperties(obj,nargin,varargin{:});
            setVarSizeAllowedStatus(obj,false);




            setSampleTimeIsFramePeriod(obj,true)
        end

        function set.SampleRate(obj,val)
            validateattributes(val,{'double'},...
            {'finite','scalar','real','positive'},'','SampleRate');
            obj.SampleRate=val;
        end

    end

    methods(Hidden)
        function setParameters(obj)
            frequencyOffsetSource=~strcmp(obj.FrequencyOffsetSource,...
            'Property');
            setSampleRate(obj,obj.SampleRate);
            obj.compSetParameters({...
            obj.PhaseOffset,...
            double(frequencyOffsetSource),...
            obj.FrequencyOffset});
        end
    end

    methods(Access=protected)
        function flag=isInactivePropertyImpl(obj,prop)
            props={};
            if strcmpi(obj.FrequencyOffsetSource,'Input port')
                props={'FrequencyOffset'};
            end
            flag=ismember(prop,props);
        end

        function setPortDataTypeConnections(obj)
            setPortDataTypeConnection(obj,1,1);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='commrflib2/Phase/Frequency Offset';
        end

        function props=getDisplayPropertiesImpl()
            props={...
            'PhaseOffset',...
            'FrequencyOffsetSource',...
            'FrequencyOffset',...
            'SampleRate'};
        end



        function tunePropsMap=getTunablePropertiesMap()


            tunePropsMap.FrequencyOffset=2;
        end
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end
end



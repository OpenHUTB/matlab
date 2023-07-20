classdef CompiledSampleTimes<handle
    properties(SetAccess=private,GetAccess=public)
SampleTimes
    end

    methods(Access=public)
        function this=CompiledSampleTimes(handle)
            if~ishandle(handle)
                throw(MException(message('Simulink:modelReference:convertToModelReference_InvalidInputArgument_InvalidHandleType')));
            end

            sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);
            obj=get_param(handle,'Object');
            if isa(obj,'Simulink.Port')
                this.SampleTimes=Simulink.ModelReference.Conversion.Utilities.cellify(get_param(handle,'CompiledPortSampleTime'));
            elseif isa(obj,'Simulink.Block')
                this.SampleTimes=Simulink.ModelReference.Conversion.Utilities.cellify(get_param(handle,'CompiledSampleTime'));
            else

                throw(MException(message('Simulink:modelReference:convertToModelReference_InvalidInputArgument_InvalidHandleType')));
            end
            delete(sess);
        end

        function sampleTimes=getSampleTimes(this)
            sampleTimes=this.SampleTimes;
        end

        function status=hasSampleTime(this,sampleTime)
            status=any(cellfun(@(val)isequal(val,sampleTime),this.SampleTimes));
        end
    end
end

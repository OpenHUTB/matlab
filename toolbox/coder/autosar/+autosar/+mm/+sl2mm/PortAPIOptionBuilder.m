classdef PortAPIOptionBuilder<handle





    methods(Static,Access=public)
        function createOrUpdatePortAPIOption(m3iPort)



            m3iPortAPIOption=autosar.mm.sl2mm.PortAPIOptionBuilder.getOrCreatePortAPIOptionForPort(m3iPort);
            errorHandlingValue=Simulink.metamodel.arplatform.behavior.DataTransformationErrorHandlingEnum.TransformerErrorHandling;
            m3iPortAPIOption.ErrorHandling=errorHandlingValue;
        end
    end

    methods(Static,Access=private)
        function m3iPortAPIOption=getOrCreatePortAPIOptionForPort(m3iPort)
            if m3iPort.has('PortAPIOption')
                m3iPortAPIOption=m3iPort.PortAPIOption;
                return;
            end

            m3iPortAPIOption=Simulink.metamodel.arplatform.behavior.PortAPIOption(m3iPort.modelM3I);
            m3iPortAPIOption.Port=m3iPort;

            m3iBehavior=...
            autosar.mm.sl2mm.PortAPIOptionBuilder.getM3IBehaviorFromPort(m3iPort);
            m3iBehavior.PortAPIOptions.append(m3iPortAPIOption);
        end

        function m3iBehavior=getM3IBehaviorFromPort(m3iPort)
            m3iComp=m3iPort.containerM3I;
            m3iBehavior=m3iComp.Behavior;
        end
    end
end



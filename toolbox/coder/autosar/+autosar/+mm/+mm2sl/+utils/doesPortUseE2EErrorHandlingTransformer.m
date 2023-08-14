function portUsesE2EErrorTransformer=doesPortUseE2EErrorHandlingTransformer(m3iPort)




    portUsesE2EErrorTransformer=false;
    if~m3iPort.has('PortAPIOption')

        return;
    end
    m3iPortAPIOption=m3iPort.PortAPIOption;
    portUsesE2EErrorTransformer=~isempty(m3iPortAPIOption.ErrorHandling)&&...
    m3iPortAPIOption.ErrorHandling==...
    Simulink.metamodel.arplatform.behavior.DataTransformationErrorHandlingEnum.TransformerErrorHandling;
end

function setEndToEndProtectionMethod(self,m3iBehavior)





    isUsingTransformerErrorHandling=any(m3i.map(@(x)...
    (x.ErrorHandling==Simulink.metamodel.arplatform.behavior.DataTransformationErrorHandlingEnum.TransformerErrorHandling),...
    m3iBehavior.PortAPIOptions));
    if isUsingTransformerErrorHandling
        protectionMethod='TransformerError';
    else
        protectionMethod='ProtectionWrapper';
    end
    mapObj=autosar.api.getSimulinkMapping(self.MdlName,self.ChangeLogger);
    mapObj.setDataDefaults('InportsOutports','EndToEndProtectionMethod',protectionMethod);
end

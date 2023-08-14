function isSingleChoiceBlock=isSingleChoiceVariantInfoBlock(blockH)








    isSingleChoiceBlock=Simulink.variant.utils.isVariantSimulinkFunction(blockH)||...
    Simulink.variant.utils.isVariantIRTSubsystem(blockH);
end

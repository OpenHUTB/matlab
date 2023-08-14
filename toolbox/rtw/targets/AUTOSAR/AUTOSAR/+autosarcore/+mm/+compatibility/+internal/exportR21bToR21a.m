function exportR21bToR21a(transformer)





    transformer.skipElement('packagedElement','Simulink.metamodel.arplatform.variant.PostBuildVariantCriterionValueSet');
    transformer.skipElement('packagedElement','Simulink.metamodel.arplatform.variant.PostBuildVariantCriterion');
    transformer.skipElement('PostBuildVariantCondition','Simulink.metamodel.arplatform.variant.PostBuildVariantCondition');
    transformer.skipAttribute('packagedElement','Simulink.metamodel.arplatform.variant.PredefinedVariant','PostBuildVariantCriterionValueSet');
    transformer.skipAttribute('variationPoint','Simulink.metamodel.arplatform.variant.VariationPoint','PostBuildVariantCondition');
    transformer.skipAttribute('variationPointProxy','Simulink.metamodel.arplatform.variant.VariationPointProxy','ImplementationDataType');
    transformer.skipAttribute('variationPointProxy','Simulink.metamodel.arplatform.variant.VariationPointProxy','PostBuildValueAccess');
    transformer.skipAttribute('variationPointProxy','Simulink.metamodel.arplatform.variant.VariationPointProxy','PostBuildVariantCondition');

end



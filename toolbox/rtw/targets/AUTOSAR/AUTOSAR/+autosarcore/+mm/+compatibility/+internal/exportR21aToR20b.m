function exportR21aToR20b(transformer)




    transformer.skipAttribute('packagedElement',...
    'Simulink.metamodel.arplatform.manifest.Process','ProcessDesign');
    transformer.skipAttribute('packagedElement',...
    'Simulink.metamodel.arplatform.manifest.ServiceInstanceToPortMapping','ProcessDesign');
    transformer.skipElement('packagedElement','Simulink.metamodel.arplatform.manifest.ProcessDesign');
end



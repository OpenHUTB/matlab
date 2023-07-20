function exportR18bToR18a(transformer)





    typesWithQualifier={'Boolean','Enumeration','FloatingPoint',...
    'FixedPoint','Integer'};
    for ii=1:length(typesWithQualifier)
        transformer.skipAttribute('packagedElement',...
        ['Simulink.metamodel.types.',typesWithQualifier{ii}],'Qualifier');
        transformer.skipAttribute('packagedElement',...
        ['Simulink.metamodel.types.',typesWithQualifier{ii}],'IsConst');
        transformer.skipAttribute('packagedElement',...
        ['Simulink.metamodel.types.',typesWithQualifier{ii}],'IsVolatile');
    end
end



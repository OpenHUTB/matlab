function sanityCheck(systemUnderDesign)







    compatibilityCheckOnly=true;
    ra=Simulink.FixedPointAutoscaler.RangeAnalyzer(systemUnderDesign,compatibilityCheckOnly);
    ra.analyze;
end
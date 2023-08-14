function isConstrained=isSpacingConstrainedByLookupnDEvenSpacingMode(useLUTSettings,fixedPointType,numberOfPoints)














    isConstrained=useLUTSettings&&fixedPointType.Signed&&(numberOfPoints==2);
end

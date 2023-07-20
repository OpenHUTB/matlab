function ishwfr=isInHwFriendly(~,hC)




    ishwfr=hC.Owner.hasSLHWFriendlySemantics||hC.Owner.getWithinHWFriendlyHierarchy;
end


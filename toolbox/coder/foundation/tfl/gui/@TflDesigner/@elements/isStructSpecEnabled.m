function ret=isStructSpecEnabled(~)




    fc=coder.internal.FeatureControl;
    ret=(fc.EnableCRLStructArgForLookup==2);
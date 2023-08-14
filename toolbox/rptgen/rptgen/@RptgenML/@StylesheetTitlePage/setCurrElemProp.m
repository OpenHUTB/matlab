function acceptedValue=setCurrElemProp(h,newValue,prop)




    elem=h.Format.getIncludeElement(h.IncludedElementNames(h.CurrIncludeElementIdx+1));
    elem.(prop)=newValue;
    acceptedValue=newValue;
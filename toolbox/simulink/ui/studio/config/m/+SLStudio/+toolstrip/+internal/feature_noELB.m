function result=feature_noELB()
    result=(matlab.internal.feature("EmbeddedLB")~=1);
end

function status=isSigningEnabled()






    featureValue=matlab.internal.feature("MAVLinkSigningSupport");
    status=featureValue~=uint32(0);

end


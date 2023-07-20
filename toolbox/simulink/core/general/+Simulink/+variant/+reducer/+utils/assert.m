function assert(boolFlag,msg)








    if Simulink.variant.reducer.utils.getDebugLevel()<1
        return;
    end

    if nargin==1
        Simulink.variant.utils.assert(boolFlag);
    else
        Simulink.variant.utils.assert(boolFlag,msg);
    end

end

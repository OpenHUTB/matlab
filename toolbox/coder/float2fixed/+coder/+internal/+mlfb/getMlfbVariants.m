function[origMLFB,fixptMLFB]=getMlfbVariants(mlfb)


    if~isMLFB(mlfb)

        [origMLFB,fixptMLFB]=fetchMLFBVariants(mlfb);
    else
        varSubSys=get_param(mlfb,'Parent');
        [origMLFB,fixptMLFB]=fetchMLFBVariants(varSubSys);
    end

    if~isempty(origMLFB)
        origMLFB=Simulink.ID.getSID(origMLFB);
    end

    if~isempty(fixptMLFB)
        fixptMLFB=Simulink.ID.getSID(fixptMLFB);
    end
end
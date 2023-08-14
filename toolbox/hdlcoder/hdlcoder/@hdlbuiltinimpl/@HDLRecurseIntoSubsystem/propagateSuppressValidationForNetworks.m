






function propagateSuppressValidationForNetworks(impl,hChildNetwork,blockPath)

    if(~impl.SuppressValidation)
        return;
    end


    hChildNetwork.setSuppressValidation(blockPath);


    vComps=hChildNetwork.Components;
    for jitr=1:length(vComps)
        hC=vComps(jitr);
        if~hC.isNetworkInstance()
            continue;
        end
        hC.ReferenceNetwork.setSuppressValidation(blockPath);
    end

end

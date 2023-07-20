function needsFullModelGen=needsFullModelGenForDut(this)














    needsFullModelGen=false;
    hPir=this.hPir;

    if strcmpi(this.ShowCodeGenPIR,'yes')
        needsFullModelGen=true;
        return;
    end


    vNetworks=hPir.Networks;
    for i=1:length(vNetworks)
        hN=vNetworks(i);

        if hN.renderCodegenPir
            needsFullModelGen=true;
            return;
        end

        vComps=hN.Components;
        for j=1:length(vComps)
            hC=vComps(j);

            if strcmp(hC.ClassName,'filter_comp')
                needsFullModelGen=true;
            elseif strcmp(hC.ClassName,'ctx_ref_comp')
                needsFullModelGen=true;
            elseif hC.isBlackBox
                if hC.optimizeBBoxModelGen||hC.isTimingController||hC.Synthetic
                    needsFullModelGen=false;
                else


                    needsFullModelGen=true;
                end
            elseif hC.getIsPipelineReg

                needsFullModelGen=true;
            end

            if needsFullModelGen

                return;
            end
        end
    end

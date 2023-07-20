function optimize=optimizeForModelGen(this,~,hC)



    optimize=true;
    isNFP=targetcodegen.targetCodeGenerationUtils.isNFPMode;
    if~(isNFP&&isFloatType(hC.PirOutputSignals(1).Type))
        [~,~,~,inputSigns]=this.getBlockInfo(hC);
        if(numel(inputSigns)>2&&contains(inputSigns,'-'))

            optimize=false;
        end
    end
end

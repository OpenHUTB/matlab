
function[hasConv,hasFC,convModuleIR,fcModuleIR,hasGAPinConv,hasGAPinFC,outFeatures]=checkDeployableIR(fpgaLayer)


    hasConv=false;
    convModuleIR=[];
    hasFC=false;
    hasGAPinConv=false;
    hasGAPinFC=false;
    outFeatures=1;
    fcModuleIR=[];
    deployableIR=fpgaLayer.getDepolyableIR();
    activationLayer=fpgaLayer.getActivationLayer();

    for ii=1:length(deployableIR)
        moduleIR=deployableIR{ii};
        moduleIRType=moduleIR.type;
        switch moduleIRType
        case 'FPGA_Conv'
            hasConv=true;
            convModuleIR=moduleIR;

            for jj=1:numel(convModuleIR.params)
                params=convModuleIR.params{jj};
                if(params.lrnK==10)
                    hasGAPinConv=true;
                    continue;
                end
            end


            if(~isempty(activationLayer)&&hasActivationLayer(moduleIR.params,activationLayer))
                break;
            end
        case 'FPGA_FC'
            hasFC=true;
            fcModuleIR=moduleIR;
            params=fcModuleIR.params{end};
            if(strcmpi(params.type,'FPGA_GAP2D'))
                hasGAPinFC=true;
                outFeatures=params.outputFeatureNum;
                break;
            end


        otherwise

        end
    end

end

function result=hasActivationLayer(deployableIRParams,activationLayer)
    result=false;
    for jj=1:length(deployableIRParams)
        layerIR=deployableIRParams{jj};
        if(any(strcmp(layerIR.frontendLayers,activationLayer)))
            result=true;
            return;
        end
    end
end

function[hasGAPinConv]=checkDeployableIRDAG(fpgaLayer)








    import dnnfpga.dagCompile.*;
    hasGAPinConv=false;
    sortedComponents=fpgaLayer.getDepolyableIR().sortedComponents';

    for component=sortedComponents


        if component.hasKind(LayerKind.Conv)
            convModuleIR=component.LegLevelIR{1};
            for jj=1:numel(convModuleIR.params)
                params=convModuleIR.params{jj};
                if(params.lrnK==10)
                    hasGAPinConv=true;
                    continue;
                end
            end
        end
    end

end
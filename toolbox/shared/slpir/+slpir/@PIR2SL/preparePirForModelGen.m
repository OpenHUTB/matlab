function preparePirForModelGen(this)





    hPir=this.hPir;




    vNetworks=hPir.Networks;
    for i=1:length(vNetworks)
        hN=vNetworks(i);
        showCodeGenPir=this.renderCodeGenPIR(hN);
        prepareNetwork(this,hN,showCodeGenPir);
    end

end


function prepareNetwork(this,hN,showCodeGenPir)

    if isValidNetwork(hN,showCodeGenPir)
        hN.setShouldDraw(true);
    end


    if hN.isBusExpansionSubsystem()
        origBlkh=get_param(hN.FullPath,'Handle');
        if~isempty(origBlkh)&&...
            strcmp(get_param(origBlkh,'BlockType'),'SubSystem')
            hN.renderCodegenPir(true);
        end
    end

    vComps=hN.Components;
    for j=1:length(vComps)
        hC=vComps(j);
        isPipeReg=prepareComp(this,hC,showCodeGenPir);
        if isPipeReg
            hN.renderCodegenPir(true);
        end
        if hC.isNetworkInstance&&hC.ReferenceNetwork.isForEachSubsystem
            hN.renderCodegenPir(true);
        end
    end


end


function isPipelineReg=prepareComp(this,hC,showCodeGenPir)
    isPipelineReg=false;


    if hC.alwaysDraw
        hC.setShouldDraw(true);
    elseif hC.alwaysDontDraw
        hC.setShouldDraw(false);
    elseif~hC.Synthetic

        if hC.isBlackBox&&hC.elaborationHelper&&showCodeGenPir



            hC.setShouldDraw(false);
        elseif this.isChevronTriggPort(hC)
            hC.setShouldDraw(false);
        else
            hC.setShouldDraw(true);
        end
    elseif hC.isBlackBox&&hC.elaborationHelper

        hC.setShouldDraw(false);
    elseif hC.getIsPipelineReg

        hC.setShouldDraw(true);
        isPipelineReg=true;
    elseif hC.isTimingController

        hC.setShouldDraw(false);
    elseif needToDrawPirObj(hC,showCodeGenPir)

        hC.setShouldDraw(true);
    elseif hC.isNetworkInstance&&(hC.SimulinkHandle==-1)


        should_draw=hC.ReferenceNetwork.isMarkedForPirModelgen();

        hC.setShouldDraw(should_draw);
    end

end


function valid=isValidNetwork(hN,showCodeGenPir)



    if~hN.Synthetic
        valid=true;
    elseif hN.isRAM
        valid=false;
    else
        if needToDrawPirObj(hN,showCodeGenPir)
            valid=true;
        else
            valid=false;
        end
    end

end



function draw=needToDrawPirObj(pirObj,showCodeGenPir)

    draw=pirObj.shouldDraw;

    if~draw

        if showCodeGenPir

            draw=true;
        end
    end

end



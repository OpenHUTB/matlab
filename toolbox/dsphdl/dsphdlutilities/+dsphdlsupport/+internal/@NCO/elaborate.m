function nComp=elaborate(this,hN,hC)





    blockInfo=getBlockInfo(this,hC);

    inMode=blockInfo.inMode;

    inportnames={};
    outportnames={};

    if inMode(1)
        inportnames{1}='inc';
    end

    if inMode(2)
        offsetIdx=2-(1-inMode(1));
        inportnames{offsetIdx}='offset';
    end

    if inMode(3)
        ditherIdx=3-(2-sum(inMode(1:2)));
        inportnames{ditherIdx}='dither';
    end

    if inMode(4)
        resetIdx=4-(3-sum(inMode(1:3)));
        inportnames{resetIdx}='resetPhase';
    end
    if inMode(5)
        validIdx=5-(4-sum(inMode(1:4)));
        inportnames{validIdx}='validIn';
    end


    outMode=blockInfo.outMode;

    if outMode(1)
        outportnames{1}='sine';
    end

    if outMode(2)
        if outMode(1)
            outportnames{2}='cosine';
        else
            outportnames{1}='cosine';
        end
    end

    if outMode(3)
        outportnames{1}='complexexp';
    end

    if outMode(4)
        outportnames{length(outportnames)+1}='phase';
    end
    outportnames{length(outportnames)+1}='validOut';



    topNet=pirelab.createNewNetworkWithInterface(...
    'Network',hN,...
    'RefComponent',hC,...
    'InportNames',inportnames,...
    'OutportNames',outportnames...
    );
    topNet.addComment('NCO');


    if blockInfo.SamplesPerFrame==1
        this.elaborateNCONetworkS(topNet,blockInfo);
    else
        this.elaborateNCONetworkV(topNet,blockInfo);
    end


    nComp=pirelab.instantiateNetwork(hN,topNet,hC.PirInputSignals,hC.PirOutputSignals,hC.Name);
end

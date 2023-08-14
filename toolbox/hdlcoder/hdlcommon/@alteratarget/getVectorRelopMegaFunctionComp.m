function hC=getVectorRelopMegaFunctionComp(targetCompInventory,hN,hInSignals,hOutSignals,alteraCompName,getScalarRelopMegaFunctionComp,pipeline,relopType)



    for i=1:length(hInSignals)
        [dimlen,baseTypeIn]=pirelab.getVectorTypeInfo(hInSignals(i));
        for ii=1:dimlen
            hNewInSignals(i,ii)=hN.addSignal(baseTypeIn,sprintf('%s_in_%d_%d',alteraCompName,ii,i));%#ok<AGROW>
        end
    end

    for i=1:length(hOutSignals)
        [dimlen,baseTypeOut]=pirelab.getVectorTypeInfo(hOutSignals(i));
        for ii=1:dimlen
            hNewOutSignals(i,ii)=hN.addSignal(baseTypeOut,sprintf('%s_out_%d_%d',alteraCompName,ii,i));%#ok<AGROW>
        end
    end

    for i=1:length(hInSignals)

        hC=pirelab.getDemuxComp(hN,hInSignals(i),hNewInSignals(i,:));
    end


    newComps=hdlhandles(dimlen,1);
    for ii=dimlen:-1:1
        newComps(ii)=getScalarRelopMegaFunctionComp(targetCompInventory,hN,hNewInSignals(:,ii),hNewOutSignals(:,ii),alteraCompName,pipeline,relopType);
    end

    for i=1:length(hOutSignals)

        pirelab.getMuxComp(hN,hNewOutSignals(i,:),hOutSignals(i));%#ok<*NASGU>
    end

    hN.groupComponents(newComps);

end


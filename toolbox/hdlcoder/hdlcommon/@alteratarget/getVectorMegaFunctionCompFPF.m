function hC=getVectorMegaFunctionCompFPF(hN,hInSignals,hOutSignals,alteraCompName,latency,getScalarMegaFunctionComp)



    maxDimLen=1;
    for i=1:length(hInSignals)
        [dimLen(i),baseTypeIn(i)]=pirelab.getVectorTypeInfo(hInSignals(i));%#ok<AGROW>
        if dimLen(i)>maxDimLen
            maxDimLen=dimLen(i);
        end
    end



    for i=1:length(hInSignals)
        if dimLen(i)==1
            for ii=1:maxDimLen
                hNewInSignals(i,ii)=hInSignals(i);%#ok<AGROW>
            end
        else
            for ii=1:maxDimLen
                hNewInSignals(i,ii)=hN.addSignal(baseTypeIn(i),sprintf('%s_in_%d_%d',alteraCompName,ii,i));
                hNewInSignals(i,ii).SimulinkRate=hInSignals(i).SimulinkRate;
            end
        end
    end

    for i=1:length(hOutSignals)
        [dimlen,baseTypeOut]=pirelab.getVectorTypeInfo(hOutSignals(i));
        for ii=1:dimlen
            hNewOutSignals(i,ii)=hN.addSignal(baseTypeOut,sprintf('%s_out_%d_%d',alteraCompName,ii,i));%#ok<AGROW>
            hNewOutSignals(i,ii).SimulinkRate=hOutSignals(i).SimulinkRate;
        end
    end

    for i=1:length(hInSignals)

        if dimLen(i)>1
            hC=pirelab.getDemuxComp(hN,hInSignals(i),hNewInSignals(i,:));
        end
    end


    newComps=hdlhandles(dimlen,1);
    for ii=dimlen:-1:1
        newComps(ii)=getScalarMegaFunctionComp(hN,hNewInSignals(:,ii),hNewOutSignals(:,ii),alteraCompName,latency);
    end

    for i=1:length(hOutSignals)

        pirelab.getMuxComp(hN,hNewOutSignals(i,:),hOutSignals(i));%#ok<*NASGU>
    end

    hN.groupComponents(newComps);

end



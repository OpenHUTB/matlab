function hC=getVectorCoreGenComp(targetCompInventory,hN,hInSignals,hOutSignals,xilinxCompName,getScalarCoreGenComp,pipeline)
    if nargin<7
        pipeline=-1;
    end
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
                hNewInSignals(i,ii)=hN.addSignal(baseTypeIn(i),sprintf('%s_in_%d_%d',xilinxCompName,ii,i));%#ok<AGROW>
            end
        end
    end

    for i=1:length(hOutSignals)
        [dimlen,baseTypeOut]=pirelab.getVectorTypeInfo(hOutSignals(i));
        for ii=1:dimlen
            hNewOutSignals(i,ii)=hN.addSignal(baseTypeOut,sprintf('%s_out_%d_%d',xilinxCompName,ii,i));%#ok<AGROW>
        end
    end

    for i=1:length(hInSignals)

        if dimLen(i)>1
            hC=pirelab.getDemuxComp(hN,hInSignals(i),hNewInSignals(i,:));
        end
    end


    newComps=hdlhandles(dimlen,1);
    for ii=dimlen:-1:1
        if pipeline==-1
            newComps(ii)=getScalarCoreGenComp(targetCompInventory,hN,hNewInSignals(:,ii),hNewOutSignals(:,ii),xilinxCompName);
        else
            newComps(ii)=getScalarCoreGenComp(targetCompInventory,hN,hNewInSignals(:,ii),hNewOutSignals(:,ii),xilinxCompName,pipeline);
        end
    end

    for i=1:length(hOutSignals)

        pirelab.getMuxComp(hN,hNewOutSignals(i,:),hOutSignals(i));%#ok<*NASGU>
    end

    hN.groupComponents(newComps);

end


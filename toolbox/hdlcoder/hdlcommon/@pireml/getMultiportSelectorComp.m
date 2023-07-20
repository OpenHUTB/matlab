function newComp=getMultiportSelectorComp(hN,hInSignals,hOutSignals,...
    rowsOrCols,idxCellArray,compName)


    selectRow=strcmp(rowsOrCols,'Rows');
    numOutports=numel(hOutSignals);


    if numOutports==1
        flatIdxVect=idxCellArray;
        if iscell(flatIdxVect)
            flatIdxVect=flatIdxVect{:};
        end
        flatLenVect=numel(flatIdxVect);
    else
        flatIdxVectLen=0;
        for ii=1:numOutports
            flatIdxVectLen=flatIdxVectLen+numel(idxCellArray{ii});
        end
        flatIdxVect=zeros(1,flatIdxVectLen);
        flatLenVect=zeros(1,numOutports);
        pos=1;
        for ii=1:numOutports
            flatLenVect(ii)=numel(idxCellArray{ii});
            endpos=pos+flatLenVect(ii)-1;
            flatIdxVect(pos:endpos)=idxCellArray{ii};
            pos=endpos+1;
        end
    end

    vec=hdlsignalvector(hInSignals(1));

    flatIdxVect=clipindex(flatIdxVect,vec);


    if hInSignals(1).Type.isArrayType
        inSigDemux=pirelab.demuxSignal(hN,hInSignals(1));
    else
        inSigDemux=hInSignals(1);
    end

    startidx=1;
    for k=1:numOutports


        if(length(vec)>1&&...
            ((selectRow==1&&vec(1)==1&&vec(2)>1)||...
            (selectRow==0&&vec(1)>1&&vec(2)==1)))||...
            (length(vec)==1&&vec>1&&selectRow==0)
            newComp=pirelab.getWireComp(hN,hInSignals(1),hOutSignals(k),compName);
        elseif(max(vec)==0)
            outvec=hdlsignalvector(hOutSignals(k));
            if(max(outvec)==0)

                newComp=pirelab.getWireComp(hN,hInSignals(1),hOutSignals(k),compName);
            else

                inSigs=repmat(hInSignals(1),max(outvec),1);
                newComp=pirelab.getMuxComp(hN,inSigs,hOutSignals(k),compName);
            end
        else
            endidx=startidx+flatLenVect(k)-1;
            elementarray=flatIdxVect(startidx:endidx);
            if hOutSignals(k).Type.isArrayType
                outMuxName=sprintf('%s_mux',hOutSignals(k).Name);
                newComp=pirelab.getMuxComp(hN,inSigDemux(elementarray),hOutSignals(k),outMuxName);
            else
                newComp=pirelab.getWireComp(hN,inSigDemux(elementarray),hOutSignals(k));
            end

            startidx=startidx+flatLenVect(k);
        end
    end
end


function flatIdxVect=clipindex(flatIdxVect,vec)




    vecdim=max(vec);
    if vecdim~=0

        for k=1:length(flatIdxVect)
            if flatIdxVect(k)<1,
                flatIdxVect(k)=1;
            elseif flatIdxVect(k)>vecdim,
                flatIdxVect(k)=vecdim;
            end
        end
    end
end

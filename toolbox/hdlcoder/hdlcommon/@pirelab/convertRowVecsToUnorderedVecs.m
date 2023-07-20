function convertedSigs=convertRowVecsToUnorderedVecs(hN,hInSignals)

    numIn=numel(hInSignals);
    rowVec=zeros(1,numIn,'int8');
    unorderedVec=zeros(1,numIn,'int8');
    dimVec=zeros(1,numIn);
    for ii=1:numIn
        hT=hInSignals(ii).Type;
        if hT.isArrayType
            dims=hT.Dimensions;
            if numel(dims)>1&&all(dims>1)

                convertedSigs=hInSignals;
                return;
            end
            dimVec(ii)=dims;
            if hT.isRowVector
                rowVec(ii)=true;
            elseif~hT.isColumnVector
                unorderedVec(ii)=true;
            end
        end
    end

    convertedSigs=hInSignals;
    if any(unorderedVec)&&any(rowVec)&&all(dimVec==dimVec(1))


        for ii=1:numIn
            hS=hInSignals(ii);
            if rowVec(ii)
                hT=hS.Type;
                hBT=hT.BaseType;
                vecLen=hT.Dimensions;

                newType=hN.getType('Array','BaseType',hBT,'Dimensions',vecLen);
                colSig=hN.addSignal(newType,sprintf('%s_reshape',hS.Name));
                pirelab.getDTCComp(hN,hS,colSig,'Floor','Wrap','RWV','reshape_dtc');
                convertedSigs(ii)=colSig;
            end
        end
    end
end

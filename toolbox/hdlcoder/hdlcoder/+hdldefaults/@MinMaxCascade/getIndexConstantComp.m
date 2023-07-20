function constIndexSignals=getIndexConstantComp(this,hN,dimLen,idxBase,indexType,isDspVectorOut)




    indexName=sprintf('const_idx');


    for ii=1:dimLen
        if isDspVectorOut

            if indexType.isDoubleType
                if strcmp(idxBase,'One')
                    constValue(ii)=double(1);%#ok<AGROW>
                else
                    constValue(ii)=double(0);%#ok<AGROW>
                end
            else
                if strcmp(idxBase,'One')
                    constValue(ii)=uint32(1);%#ok<AGROW>
                else
                    constValue(ii)=uint32(0);%#ok<AGROW>
                end
            end
        else

            if indexType.isDoubleType
                if strcmp(idxBase,'One')
                    constValue(ii)=double(ii);%#ok<AGROW>
                else
                    constValue(ii)=double(ii-1);%#ok<AGROW>
                end
            else
                if strcmp(idxBase,'One')
                    constValue(ii)=uint32(ii);%#ok<AGROW>
                else
                    constValue(ii)=uint32(ii-1);%#ok<AGROW>
                end
            end
        end
    end


    if dimLen>1
        constType=pirelab.getPirVectorType(indexType,dimLen);
    else
        constType=indexType;
    end
    constIndexSignals=hN.addSignal(constType,indexName);


    pirelab.getConstComp(hN,constIndexSignals,constValue);

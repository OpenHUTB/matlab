function cgirComp=getBitSliceComp(hN,hInSignals,hOutSignals,msbPos,lsbPos,compName)







    if(nargin<6)
        compName='slice';
    end

    hInType=hInSignals.Type;
    hOutType=hOutSignals.Type;

    numElems=numel(msbPos);

    assert(numElems==numel(lsbPos));

    hInSigs=[];
    hOutSigs=[];

    if hOutType.isArrayType&&(numElems>1)

        assert(hOutType.Dimensions==numElems);
        outBaseType=hOutType.BaseType;
        outName=hOutSignals.Name;
        for ii=1:numElems
            hOutSigs=[hOutSigs,hN.addSignal(outBaseType,[outName,'(',num2str(ii),')'])];%#ok<AGROW>
        end
        if hOutType.isRowVector

            cgirCompMux=pirelab.getConcatenateComp(hN,hOutSigs,hOutSignals,'Multidimensional array',2);
        else


            cgirCompMux=pirelab.getConcatenateComp(hN,hOutSigs,hOutSignals,'Vector',1);
        end
    else
        assert(numElems==1);
        hOutSigs=hOutSignals;
    end

    if numElems>1
        if hInType.isArrayType

            assert(hInType.Dimensions==numElems);
            inBaseType=hInType.BaseType;
            inName=hInSignals.Name;
            for ii=1:numElems
                hInSigs=[hInSigs,hN.addSignal(inBaseType,[inName,'(',num2str(ii),')'])];%#ok<AGROW>
            end
            pirelab.getDemuxComp(hN,hInSignals,hInSigs);
        else
            for ii=1:numElems
                hInSigs=[hInSigs,hInSignals];%#ok<AGROW>
            end
        end
    else
        hInSigs=hInSignals;
    end

    for ii=1:numElems
        if hInType.isEqual(hOutType)
            cgirComp=pirelab.getWireComp(hN,hInSignals(ii),hOutSignals(ii),compName);
        else
            cgirComp=pircore.getBitSliceComp(hN,hInSigs(ii),hOutSigs(ii),msbPos(ii),lsbPos(ii),compName);
        end
    end

    if numElems>1
        cgirComp=cgirCompMux;
    end
end


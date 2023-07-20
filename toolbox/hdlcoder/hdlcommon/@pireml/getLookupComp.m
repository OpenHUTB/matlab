function cgirComp=getLookupComp(hN,hInSignals,hOutSignals,compName,emlScript,emlParams)











    if any(arrayfun(@(x)x.Type.isArrayType,hInSignals))

        nDims=numel(hInSignals);
        numTables=hOutSignals.Type.Dimensions;
        for ii=nDims:-1:1
            if hInSignals(ii).Type.isArrayType
                hInputDemux{ii}=pirelab.getDemuxCompOnInput(hN,hInSignals(ii));
            else



                hInputDemux{ii}=struct('PirOutputSignals',repmat(hInSignals(ii),[1,numTables]));
            end
        end
        [~,outType]=pirelab.getVectorTypeInfo(hOutSignals);
        origComp=hOutSignals.getConcreteDrivingComps;
        for ii=numTables:-1:1
            for jj=nDims:-1:1
                lutInSigs(jj)=hInputDemux{jj}.PirOutputSignals(ii);
            end
            hTableOutSignals(ii)=hN.addSignal(outType,sprintf('%s_tableout%d',compName,ii));
            cgirComp=getOneTable(hN,lutInSigs,hTableOutSignals(ii),compName,...
            emlScript,emlParams);
            cgirComp.copyComment(origComp);
        end
        pirelab.getMuxComp(hN,hTableOutSignals,hOutSignals,sprintf('%s_concat',compName));
    else
        cgirComp=getOneTable(hN,hInSignals,hOutSignals,compName,...
        emlScript,emlParams);
    end
end

function cgirComp=getOneTable(hN,hInSignals,hOutSignals,compName,emlScript,emlParams)

    cgirComp=hN.addComponent2(...
    'kind','cgireml',...
    'Name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'EMLFileName',emlScript,...
    'EMLParams',emlParams,...
    'EMLFlag_ParamsFollowInputs',false,...
    'EMLFlag_RunLoopUnrolling',false,...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false);

    if targetmapping.isValidDataType(hOutSignals(1).Type)
        cgirComp.setSupportTargetCodGenWithoutMapping(true);
    end

    if targetcodegen.targetCodeGenerationUtils.isNFPMode&&...
        hOutSignals(1).Type.BaseType.isFloatType
        cgirComp.setPreserveFloats(true);
    end
end



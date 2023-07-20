function cascadeExpandCgirComp_ValueAndIndex(this,hN,hC,opName,opOutType,...
    ipf,bmp,tSignalsIn,tSignalsOut,casName,indexType,idxBase)




    dimLen=pirelab.getInputDimension(tSignalsIn);
    decomp_impl_param=getDecomposition(this);
    decompose_vector=hdlcascadedecompose(dimLen,decomp_impl_param);
    numStages=length(decompose_vector);


    demuxComp=pirelab.getDemuxCompOnInput(hN,tSignalsIn);
    demuxComp.addComment(casName);
    hDemuxOutSignals=demuxComp.PirOutputSignals;


    idx=1;
    signalGroup={};
    for ii=1:numStages-1
        stageSigLen=decompose_vector(ii);
        signalGroup{end+1}=hDemuxOutSignals(idx:idx+stageSigLen-2);%#ok<AGROW>
        idx=idx+stageSigLen-1;
    end
    signalGroup{end+1}=hDemuxOutSignals(idx:end);


    nextSignals=signalGroup{end}';
    for jj=numStages:-1:1

        decomposeStage=decompose_vector(jj);


        currStageOut=hN.addSignal(opOutType,sprintf('%s_out_%d',opName,decomposeStage));
        currStageIdx=hN.addSignal(indexType,sprintf('%s_idx_out_%d',opName,decomposeStage));


        hInSignals=nextSignals;
        hOutSignals=[currStageOut,currStageIdx];
        isStartStage=jj==numStages;
        this.cascadeStageCgirComp_ValueAndIndex(hN,hC,opName,decomposeStage,ipf,bmp,hInSignals,hOutSignals,decompose_vector,isStartStage,indexType);


        if(jj~=1)
            nextSignals=[signalGroup{jj-1}',currStageOut,currStageIdx];
        end
    end


    outputComp=pirelab.getUnitDelayComp(hN,currStageOut,tSignalsOut(1),'out_reg_val');
    outputComp.addComment('---- Cascade output register ----');


    if strcmp(idxBase,'One')
        idxAddOne=hN.addSignal(indexType,'idx_add_one');
        constOne=hN.addSignal(indexType,'const_one');
        pirelab.getConstComp(hN,constOne,pirelab.getTypeInfoAsFi(indexType,'Floor','Wrap',1));

        hInSignals=[currStageIdx,constOne];
        pirelab.getAddComp(hN,hInSignals,idxAddOne);

        currStageIdx=idxAddOne;
    end
    pirelab.getUnitDelayComp(hN,currStageIdx,tSignalsOut(2),'out_reg_idx');


end





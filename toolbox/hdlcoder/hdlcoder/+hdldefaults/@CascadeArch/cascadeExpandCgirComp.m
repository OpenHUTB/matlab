function cascadeExpandCgirComp(this,hN,hC,opName,opOutType,...
    ipf,bmp,tSignalsIn,tSignalsOut,casName,cascadeNum)



    if nargin<11
        cascadeNum=0;
    end


    dimLen=pirelab.getInputDimension(tSignalsIn);
    decomp_impl_param=getDecomposition(this);
    decompose_vector=hdlcascadedecompose(dimLen,decomp_impl_param);
    numStages=length(decompose_vector);


    numInports=length(hC.PirInputPorts);
    if numInports==1
        demuxComp=pirelab.getDemuxCompOnInput(hN,tSignalsIn);
        demuxComp.addComment(casName);
        hDemuxOutSignals=demuxComp.PirOutputSignals;
    else
        hDemuxOutSignals=tSignalsIn;
    end


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


        currStageOut=hN.addSignal(opOutType,sprintf('%sout_%d',opName,decomposeStage));


        hInSignals=nextSignals;
        hOutSignals=currStageOut;
        isStartStage=jj==numStages;
        this.cascadeStageCgirComp(hN,hC,opName,decomposeStage,ipf,bmp,hInSignals,hOutSignals,decompose_vector,isStartStage,casName,cascadeNum);


        if(jj~=1)
            nextSignals=[signalGroup{jj-1}',currStageOut];
        end
    end


    outputComp=pirelab.getUnitDelayComp(hN,currStageOut,tSignalsOut(1),'outputReg');
    outputComp.addComment('---- Cascade output register ----');


end






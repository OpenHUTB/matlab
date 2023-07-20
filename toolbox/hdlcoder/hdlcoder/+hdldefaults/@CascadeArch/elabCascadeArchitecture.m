function outputComp=elabCascadeArchitecture(this,hN,hC,hSignalsIn,hSignalsOut,...
    ipf,bmp,opName,casName,cascadeNum)


    if nargin<10
        cascadeNum=0;
    end


    dimLen=pirelab.getInputDimension(hSignalsIn);
    decomp_impl_param=getDecomposition(this);
    decompose_vector=hdlcascadedecompose(dimLen,decomp_impl_param);
    numStages=length(decompose_vector);



    [~,inVldSignal,~]=hN.getClockBundle(hSignalsIn(1),1,1,1);


    upRate=decompose_vector(1);


    [~,cascadeEnbSignal,~]=hN.getClockBundle(hSignalsIn(1),upRate,1,1);

    [~,hInType]=pirelab.getVectorTypeInfo(hSignalsIn);

    opOutType=hSignalsOut.Type;


    refSLHandle=hC.SimulinkHandle;



    if numStages==1&&decompose_vector(1)==2
        hSerialNet=hN;
    else
        hSerialNet=this.elabSerialOperation(hN,opName,ipf,bmp,hInType,refSLHandle,upRate,hSignalsIn);
    end


    numInports=hC.NumberOfPirInputPorts('data');


    if numInports==1
        inputVec=decompose_vector-1;
        inputVec(end)=inputVec(end)+1;

        for ii=1:numStages
            inVecDim=inputVec(ii);
            inVecType=pirelab.getPirVectorType(hInType,inVecDim);
            inVecName=sprintf('%s_v%d',hSignalsIn.Name,decompose_vector(ii));
            inVecSignals(ii)=hN.addSignal(inVecType,inVecName);
        end

        pirelab.getDemuxComp(hN,hSignalsIn,inVecSignals);
    end



    nextSignals=inVecSignals(end);
    for jj=numStages:-1:1

        decomposeStage=decompose_vector(jj);


        currStageOut=hN.addSignal(opOutType,sprintf('%s_out_%d',opName,decomposeStage));


        hInSignals=nextSignals;
        hOutSignals=currStageOut;
        isStartStage=jj==numStages;
        this.elabCascadeStage(hN,opName,decomposeStage,ipf,bmp,hInSignals,hOutSignals,...
        isStartStage,casName,cascadeNum,inVldSignal,hSerialNet,cascadeEnbSignal);


        if(jj~=1)
            nextSignals=[inVecSignals(jj-1),currStageOut];
        end
    end


    outputComp=pirelab.getUnitDelayComp(hN,currStageOut,hSignalsOut(1),'outputReg');
    outputComp.addComment('---- Cascade output register ----');


end





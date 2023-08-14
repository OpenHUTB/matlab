function treeComp=getDetailedElabTreeArch(hN,hInSignals,hOutSignals,opName,...
    rndMode,satMode,compName,minmaxIdxBase,pipeline,minmaxISDSP,minmaxOutMode,dspMode,nfpOptions,prodWordLenMode)





    if(nargin<14)
        prodWordLenMode='expand';
    end

    if(nargin<13)
        nfpOptions.Latency=int8(0);
        nfpOptions.MantMul=int8(0);
        nfpOptions.Denormals=int8(0);
    end

    if(nargin<12)
        dspMode=int8(0);
    end


    demuxOutSignal=getDemuxComp(hN,hInSignals);


    dimLen=length(demuxOutSignal);
    numStages=ceil(log2(dimLen));


    structSignalsIn=getStageInputSignal(hN,demuxOutSignal,opName,hOutSignals,minmaxIdxBase,minmaxOutMode);


    for ii=1:numStages

        inputLen=length(structSignalsIn.tSignals);


        stageLen=ceil(inputLen/2);


        structSignalsOut=getStageOutputSignal(hN,opName,compName,ii,structSignalsIn,hOutSignals,numStages,minmaxOutMode,prodWordLenMode);


        tComp=elabTreeStage(hN,structSignalsIn,structSignalsOut,opName,ii,rndMode,satMode,compName,numStages,minmaxISDSP,minmaxOutMode,minmaxIdxBase,dspMode,nfpOptions);


        if stageLen==1
            treeComp=tComp;
        end


        if(pipeline)
            structSignalsOut=hdlarch.tree.insertPipeline(hN,structSignalsOut,opName,minmaxOutMode,ii,numStages);
        end


        structSignalsIn=structSignalsOut;
    end

    if numStages==0


        structSignalsOut=structSignalsIn;
    end


    if strcmpi(opName,'sum')||strcmpi(opName,'product')
        hFinalComp=pirelab.getDTCComp(hN,structSignalsOut.tSignals,hOutSignals,rndMode,satMode);
    else
        assert(strcmpi(opName,'min')||strcmpi(opName,'max'));

        if strcmpi(minmaxOutMode,'Value')
            hFinalComp=pirelab.getDTCComp(hN,structSignalsOut.tSignals,hOutSignals,rndMode,satMode);
        elseif strcmpi(minmaxOutMode,'Value and Index')
            hFinalComp=pirelab.getDTCComp(hN,structSignalsOut.tSignals,hOutSignals(1),rndMode,satMode);
            pirelab.getWireComp(hN,structSignalsOut.tIndex,hOutSignals(2));
        else
            hFinalComp=pirelab.getWireComp(hN,structSignalsOut.tIndex,hOutSignals);
        end
    end

    if numStages==0


        treeComp=hFinalComp;
    end

end


function treeComp=elabTreeStage(hN,structSignalsIn,structSignalsOut,opName,stageNum,rndMode,satMode,compName,numStages,minmaxISDSP,minmaxOutMode,minmaxIdxBase,dspMode,nfpOptions)


    treeComment=sprintf('---- Tree %s implementation ----',lower(opName));

    hInSignals=structSignalsIn.tSignals;


    inputLen=length(hInSignals);
    inputLenOdd=(mod(inputLen,2)==1);


    numOps=floor(inputLen/2);


    for ii=1:numOps

        if numOps>1
            newcompName=sprintf('%s_stage%d_%s%d',compName,stageNum,opName,ii);
        else
            newcompName=sprintf('%s_stage%d',compName,stageNum);
        end

        if strcmpi(opName,'sum')

            hOutSignals=structSignalsOut.tSignals;

            opInSignals=hInSignals(ii*2-1:ii*2);
            opOutSignals=hOutSignals(ii);
            treeComp=pirelab.getAddComp(hN,opInSignals,opOutSignals,rndMode,satMode,newcompName,[],'++','',-1,nfpOptions);

        elseif strcmpi(opName,'product')

            hOutSignals=structSignalsOut.tSignals;

            opInSignals=hInSignals(ii*2-1:ii*2);
            opOutSignals=hOutSignals(ii);
            treeComp=pirelab.getMulComp(hN,opInSignals,opOutSignals,rndMode,satMode,newcompName,'**','',-1,dspMode,nfpOptions);

        elseif strcmpi(opName,'min')||strcmpi(opName,'max')

            isOneBased=strcmpi(minmaxIdxBase,'One');

            if strcmpi(minmaxOutMode,'Value')
                hOutSignals=structSignalsOut.tSignals;
                opInSignals=hInSignals(ii*2-1:ii*2);
                opOutSignals=hOutSignals(ii);
                treeComp=pirelab.getMinMaxComp(hN,opInSignals,opOutSignals,newcompName,opName,minmaxISDSP,'Value',true,'',-1,nfpOptions);

            elseif strcmpi(minmaxOutMode,'Value and Index')

                hInIndex=structSignalsIn.tIndex;
                hOutSignals=structSignalsOut.tSignals;
                hOutIndex=structSignalsOut.tIndex;

                opInSignals=[hInSignals(ii*2-1:ii*2),hInIndex(ii*2-1:ii*2)];
                opOutSignals=[hOutSignals(ii),hOutIndex(ii)];
                treeComp=pirelab.getMinMaxComp(hN,opInSignals,opOutSignals,newcompName,opName,true,'Value and Index',isOneBased);

            else

                if stageNum==numStages
                    hInIndex=structSignalsIn.tIndex;
                    hOutIndex=structSignalsOut.tIndex;

                    opInSignals=[hInSignals(ii*2-1:ii*2),hInIndex(ii*2-1:ii*2)];
                    opOutSignals=hOutIndex(ii);
                    treeComp=pirelab.getMinMaxComp(hN,opInSignals,opOutSignals,newcompName,opName,true,'Index',isOneBased);
                else
                    hInIndex=structSignalsIn.tIndex;
                    hOutSignals=structSignalsOut.tSignals;
                    hOutIndex=structSignalsOut.tIndex;

                    opInSignals=[hInSignals(ii*2-1:ii*2),hInIndex(ii*2-1:ii*2)];
                    opOutSignals=[hOutSignals(ii),hOutIndex(ii)];
                    treeComp=pirelab.getMinMaxComp(hN,opInSignals,opOutSignals,newcompName,opName,true,'Value and Index',isOneBased);
                end

            end

        else
            error(message('hdlcoder:validate:treeunsupported',opName));
        end

        if stageNum==1&&ii==1
            treeComp.addComment(treeComment);
        end
    end


    if inputLenOdd
        pirelab.getDTCComp(hN,hInSignals(end),hOutSignals(end),rndMode,satMode);
        if(strcmpi(opName,'min')||strcmpi(opName,'max'))&&...
            ~strcmpi(minmaxOutMode,'Value')
            pirelab.getWireComp(hN,hInIndex(end),hOutIndex(end));
        end
    end

end


function structSignalsIn=getStageInputSignal(hN,demuxOutSignal,opName,hOutSignals,minmaxIdxBase,minmaxOutMode)

    if strcmpi(opName,'sum')
        structSignalsIn.tSignals=demuxOutSignal;
    elseif strcmpi(opName,'product')
        structSignalsIn.tSignals=demuxOutSignal;
        structSignalsIn.tReach128=false(length(demuxOutSignal),1);

    elseif strcmpi(opName,'min')||strcmpi(opName,'max')

        if strcmpi(minmaxOutMode,'Value')
            structSignalsIn.tSignals=demuxOutSignal;

        else
            structSignalsIn.tSignals=demuxOutSignal;


            if strcmpi(minmaxOutMode,'Value and Index')
                indexType=hOutSignals(2).Type.getLeafType;
            else
                indexType=hOutSignals(1).Type.getLeafType;
            end
            dimLen=length(demuxOutSignal);
            constIndexSignals=getIndexConstantComp(hN,dimLen,minmaxIdxBase,indexType,demuxOutSignal(1).SimulinkRate);
            structSignalsIn.tIndex=constIndexSignals;
        end

    else
        error(message('hdlcoder:validate:treeunsupported',opName));
    end

end


function structSignalsOut=getStageOutputSignal(hN,opName,compName,stageNum,structSignalsIn,hOutSignals,numStages,minmaxOutMode,prodWordLenMode)


    inputLen=length(structSignalsIn.tSignals);

    tInType=structSignalsIn.tSignals(1).Type.getLeafType;


    stageLen=ceil(inputLen/2);

    if strcmpi(opName,'sum')
        if(pirelab.hasComplexType(structSignalsIn.tSignals(1).Type))
            tInType=pirelab.getComplexType(structSignalsIn.tSignals(1).Type);
        else
            tInType=structSignalsIn.tSignals(1).Type.getLeafType;
        end


        if structSignalsIn.tSignals(1).Type.isArrayType
            [dimLen,~]=pirelab.getVectorTypeInfo(structSignalsIn.tSignals(1));
            tInType=pirelab.createPirArrayType(tInType,dimLen);
        end


        tOutType=hdlarch.tree.getStageOutputType(tInType,opName);

        structSignalsOut.tSignals=getOneStageOutputSignal(hN,tOutType,stageLen,compName,stageNum);

    elseif strcmpi(opName,'min')||strcmpi(opName,'max')
        if~(strcmpi(minmaxOutMode,'Index')&&stageNum==numStages)
            tInType=structSignalsIn.tSignals(1).Type;

            tOutType=hdlarch.tree.getStageOutputType(tInType,opName);

            structSignalsOut.tSignals=getOneStageOutputSignal(hN,tOutType,stageLen,compName,stageNum,'_val');
        end

        if~strcmpi(minmaxOutMode,'Value')

            if strcmpi(minmaxOutMode,'Value and Index')
                indexType=hOutSignals(2).Type.getLeafType;
            else
                indexType=hOutSignals(1).Type.getLeafType;
            end
            structSignalsOut.tIndex=getOneStageOutputSignal(hN,indexType,stageLen,compName,stageNum,'_idx');
        end

    elseif strcmpi(opName,'product')


        expandWordLen=strcmpi(prodWordLenMode,'expand');

        if expandWordLen



            complex_mode=false;
            tSignalsOut=hdlhandles(stageLen,1);
            tReach128Out=false(stageLen,1);

            tSignalsIn=structSignalsIn.tSignals;
            tReach128In=structSignalsIn.tReach128;


            if(pirelab.hasComplexType(hOutSignals(1).Type))
                blockOutType=pirelab.getComplexType(hOutSignals(1).Type);
                complex_mode=true;
            else
                blockOutType=hOutSignals(1).Type.getLeafType;
            end

            if(pirelab.hasComplexType(structSignalsIn.tSignals(1).Type))
                tInType=pirelab.getComplexType(structSignalsIn.tSignals(1).Type);
            else
                tInType=structSignalsIn.tSignals(1).Type.getLeafType;
            end

            if stageNum==1
                stageReach128=false;

                if(complex_mode)
                    cInType=tInType;
                    tInType=cInType.getLeafType;
                else
                    tInType=tSignalsIn(1).Type.getLeafType;
                end


                if tInType.isFloatType||(complex_mode&&tInType.isDoubleType)
                    tOutType=tInType;
                else
                    isSigned=tInType.Signed;
                    wordLength=tInType.WordLength*2;
                    fracLength=tInType.FractionLength*2;
                    tOutType=pir_fixpt_t(isSigned,wordLength,fracLength);
                    if wordLength>128
                        tOutType=blockOutType;
                        stageReach128=true;
                    end
                end

                if(complex_mode&&~tOutType.isComplexType)
                    tOutType=pir_complex_t(tOutType);
                    tInType=cInType;
                end
                inputLenOdd=mod(inputLen,2)==1;
                for ii=1:stageLen
                    toutName=sprintf('%s_stage%d_%d',compName,stageNum,ii);
                    if inputLenOdd&&ii==stageLen
                        tSignalsOut(ii)=hN.addSignal(tInType,toutName);
                        tReach128Out(ii)=false;
                    else
                        tSignalsOut(ii)=hN.addSignal(tOutType,toutName);
                        if stageReach128
                            tReach128Out(ii)=true;
                        else
                            tReach128Out(ii)=false;
                        end
                    end
                end

            else


                opLen=floor(inputLen/2);


                for ii=1:opLen
                    if(complex_mode)
                        cType1=pirelab.getComplexType(tSignalsIn(ii*2-1).Type);
                        tInType1=cType1.getLeafType;
                        cType2=pirelab.getComplexType(tSignalsIn(ii*2).Type);
                        tInType2=cType2.getLeafType;
                    else
                        tInType1=tSignalsIn(ii*2-1).Type.getLeafType;
                        tInType2=tSignalsIn(ii*2).Type.getLeafType;
                    end



                    if tInType1.isFloatType||(complex_mode&&tInType1.isDoubleType)
                        tOutType=tInType1;
                    else
                        isSigned=tInType1.Signed;
                        wordLength=tInType1.WordLength+tInType2.WordLength;
                        fracLength=tInType1.FractionLength+tInType2.FractionLength;
                        if tReach128In(ii*2-1)||tReach128In(ii*2)||wordLength>128
                            tOutType=blockOutType;
                            tReach128Out(ii)=true;
                        else
                            tOutType=pir_fixpt_t(isSigned,wordLength,fracLength);
                            tReach128Out(ii)=false;
                        end
                    end

                    if(complex_mode&&~tOutType.isComplexType)
                        tOutType=pir_complex_t(tOutType);
                    end

                    toutName=sprintf('%s_stage%d_%d',compName,stageNum,ii);
                    tSignalsOut(ii)=hN.addSignal(tOutType,toutName);
                end


                inputLenOdd=mod(inputLen,2)==1;
                if inputLenOdd
                    toutName=sprintf('%s_stage%d_%d',compName,stageNum,stageLen);
                    if(complex_mode)
                        cTypeEnd=pirelab.getComplexType(tSignalsIn(end).Type);
                        tInTypeEnd=cTypeEnd.getLeafType;
                    else
                        tInTypeEnd=tSignalsIn(end).Type.getLeafType;
                    end

                    if(complex_mode)
                        tInTypeEnd=pir_complex_t(tInTypeEnd);
                    end

                    tSignalsOut(end)=hN.addSignal(tInTypeEnd,toutName);
                    tReach128Out(end)=tReach128In(end);
                end
            end

            structSignalsOut.tSignals=tSignalsOut;
            structSignalsOut.tReach128=tReach128Out;

        else
            assert(strcmpi(prodWordLenMode,'SameAsOutput'),...
            "prodWordLenMode is not 'expand' or 'SameAsOutput'");



            complex_mode=false;
            tSignalsOut=hdlhandles(stageLen,1);
            tReach128Out=false(stageLen,1);

            tSignalsIn=structSignalsIn.tSignals;
            tReach128In=structSignalsIn.tReach128;


            if(pirelab.hasComplexType(hOutSignals(1).Type))
                blockOutType=pirelab.getComplexType(hOutSignals(1).Type);
                complex_mode=true;
            else
                blockOutType=hOutSignals(1).Type.getLeafType;
            end

            if(pirelab.hasComplexType(structSignalsIn.tSignals(1).Type))
                tInType=pirelab.getComplexType(structSignalsIn.tSignals(1).Type);
            else
                tInType=structSignalsIn.tSignals(1).Type.getLeafType;
            end

            if stageNum==1
                stageReach128=false;

                if(complex_mode)
                    cInType=tInType;
                    tInType=cInType.getLeafType;
                else
                    tInType=tSignalsIn(1).Type.getLeafType;
                end


                if tInType.isFloatType||(complex_mode&&tInType.isDoubleType)
                    tOutType=tInType;
                else
                    tOutType=blockOutType;
                    stageReach128=true;
                end

                if(complex_mode&&~tOutType.isComplexType)
                    tOutType=pir_complex_t(tOutType);
                    tInType=cInType;
                end
                inputLenOdd=mod(inputLen,2)==1;
                for ii=1:stageLen
                    toutName=sprintf('%s_stage%d_%d',compName,stageNum,ii);
                    if inputLenOdd&&ii==stageLen
                        tSignalsOut(ii)=hN.addSignal(tInType,toutName);
                        tReach128Out(ii)=false;
                    else
                        tSignalsOut(ii)=hN.addSignal(tOutType,toutName);
                        if stageReach128
                            tReach128Out(ii)=true;
                        else
                            tReach128Out(ii)=false;
                        end
                    end
                end

            else


                opLen=floor(inputLen/2);


                for ii=1:opLen
                    if(complex_mode)
                        cType1=pirelab.getComplexType(tSignalsIn(ii*2-1).Type);
                        tInType1=cType1.getLeafType;
                    else
                        tInType1=tSignalsIn(ii*2-1).Type.getLeafType;
                    end


                    if tInType1.isFloatType||(complex_mode&&tInType1.isDoubleType)
                        tOutType=tInType1;
                    else
                        tOutType=blockOutType;
                        tReach128Out(ii)=true;
                    end

                    if(complex_mode&&~tOutType.isComplexType)
                        tOutType=pir_complex_t(tOutType);
                    end

                    toutName=sprintf('%s_stage%d_%d',compName,stageNum,ii);
                    tSignalsOut(ii)=hN.addSignal(tOutType,toutName);
                end


                inputLenOdd=mod(inputLen,2)==1;
                if inputLenOdd
                    toutName=sprintf('%s_stage%d_%d',compName,stageNum,stageLen);
                    if(complex_mode)
                        cTypeEnd=pirelab.getComplexType(tSignalsIn(end).Type);
                        tInTypeEnd=cTypeEnd.getLeafType;
                    else
                        tInTypeEnd=tSignalsIn(end).Type.getLeafType;
                    end

                    if(complex_mode)
                        tInTypeEnd=pir_complex_t(tInTypeEnd);
                    end

                    tSignalsOut(end)=hN.addSignal(tInTypeEnd,toutName);
                    tReach128Out(end)=tReach128In(end);
                end
            end

            structSignalsOut.tSignals=tSignalsOut;
            structSignalsOut.tReach128=tReach128Out;

        end

    else
        error(message('hdlcoder:validate:treeunsupported',opName));
    end

end


function tSignalsOut=getOneStageOutputSignal(hN,tOutType,stageLen,compName,stageNum,appendStr)

    if nargin<6
        appendStr='';
    end

    if stageLen>1
        tSignalsOut=hdlhandles(stageLen,1);
        for ii=1:stageLen
            toutName=sprintf('%s_stage%d_%d%s',compName,stageNum,ii,appendStr);
            tSignalsOut(ii)=hN.addSignal(tOutType,toutName);
        end
    else
        toutName=sprintf('%s_stage%d%s',compName,stageNum,appendStr);
        tSignalsOut=hN.addSignal(tOutType,toutName);
    end

end


function demuxOutSignal=getDemuxComp(hN,hInSignals)
    if length(hInSignals)==1
        demuxComp=pirelab.getDemuxCompOnInput(hN,hInSignals);
        demuxOutSignal=demuxComp.PirOutputSignals;
    else
        demuxOutSignal=hInSignals;
    end
end


function constIndexSignals=getIndexConstantComp(hN,dimLen,idxBase,indexType,slRate)


    indexName=sprintf('const_idx');
    constType=indexType;
    constIndexSignals=hdlhandles(dimLen,1);


    for ii=1:dimLen
        if strcmp(idxBase,'One')
            constValue=ii;
        else
            constValue=ii-1;
        end


        constIndexSignals(ii)=hN.addSignal(constType,indexName);
        pirelab.getConstComp(hN,constIndexSignals(ii),constValue);
        constIndexSignals(ii).SimulinkRate=slRate;

    end

end



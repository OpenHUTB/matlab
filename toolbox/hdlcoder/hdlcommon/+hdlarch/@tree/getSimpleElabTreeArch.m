function treeComp=getSimpleElabTreeArch(hN,hInSignals,hOutSignals,opName,...
    rndMode,satMode,compName,minmaxIdxBase,pipeline,~,minmaxOutMode)






    muxOutSignal=getMuxComp(hN,hInSignals,compName);


    dimLen=pirelab.getInputDimension(muxOutSignal);
    numStages=ceil(log2(dimLen));


    structSignalsIn=getStageInputSignal(hN,muxOutSignal,opName,hOutSignals,minmaxIdxBase,minmaxOutMode);


    for ii=1:numStages

        inputLen=pirelab.getInputDimension(structSignalsIn.tSignals);


        stageLen=ceil(inputLen/2);


        [structSignalsOut,outTypeEx]=getStageOutputSignal(hN,opName,compName,ii,structSignalsIn,hOutSignals,numStages,minmaxOutMode,rndMode,satMode);


        tComp=elabTreeStage(hN,structSignalsIn,structSignalsOut,opName,ii,outTypeEx,compName,numStages,minmaxOutMode,rndMode,satMode);


        if stageLen==1
            treeComp=tComp;
        end


        if(pipeline)
            structSignalsOut=hdlarch.tree.insertPipeline(hN,structSignalsOut,opName,minmaxOutMode,ii,numStages);
        end


        structSignalsIn=structSignalsOut;
    end


    if strcmpi(opName,'sum')||strcmpi(opName,'product')
        pirelab.getDTCComp(hN,structSignalsOut.tSignals,hOutSignals,rndMode,satMode);
    elseif strcmpi(opName,'min')||strcmpi(opName,'max')
        if strcmpi(minmaxOutMode,'Value')
            pirelab.getDTCComp(hN,structSignalsOut.tSignals,hOutSignals,rndMode,satMode);
        elseif strcmpi(minmaxOutMode,'Value and Index')
            pirelab.getDTCComp(hN,structSignalsOut.tSignals,hOutSignals(1),rndMode,satMode);
            pirelab.getWireComp(hN,structSignalsOut.tIndex,hOutSignals(2));
        else
            pirelab.getWireComp(hN,structSignalsOut.tIndex,hOutSignals);
        end
    end

end


function treeComp=elabTreeStage(hN,structSignalsIn,structSignalsOut,opName,stageNum,outTypeEx,compName,numStages,minmaxOutMode,rndMode,satMode)


    if strcmpi(opName,'sum')
        ipf='hdleml_sum_tree';
        bmp={outTypeEx};
        hInSignals=structSignalsIn.tSignals;
        hOutSignals=structSignalsOut.tSignals;

    elseif strcmpi(opName,'product')
        ipf='hdleml_product_tree';
        hInSignals=structSignalsIn.tSignals;
        hOutSignals=structSignalsOut.tSignals;

        if stageNum==1
            bmp={outTypeEx};


            treeName=sprintf('---- Tree %s implementation ----',lower(opName));
            stageName=sprintf('%s_treestage%d',compName,stageNum);
            stageComment=sprintf('---- Tree %s stage %d ----',lower(opName),stageNum);
            stageComment=sprintf('%s\n%s',treeName,stageComment);


            treeComp=hN.addComponent2(...
            'kind','cgireml',...
            'Name',stageName,...
            'InputSignals',hInSignals,...
            'OutputSignals',hOutSignals,...
            'EMLFileName',ipf,...
            'EMLParams',bmp,...
            'BlockComment',stageComment,...
            'EMLFlag_RunLoopUnrolling',true,...
            'EMLFlag_ParamsFollowInputs',false);

        else
            hInSignals=structSignalsIn.tSignals;


            inputLen=length(hInSignals);


            numOps=floor(inputLen/2);

            for ii=1:numOps
                if numOps>1
                    newcompName=sprintf('%s_stage%d_%s%d',compName,stageNum,opName,ii);
                else
                    newcompName=sprintf('%s_stage%d',compName,stageNum);
                end


                opInSignals=hInSignals(ii*2-1:ii*2);
                opOutSignals=hOutSignals(ii);
                bmp=outTypeEx(ii);


                stageComment=sprintf('---- Tree %s stage %d ----',lower(opName),stageNum);


                treeComp=hN.addComponent2(...
                'kind','cgireml',...
                'Name',newcompName,...
                'InputSignals',opInSignals,...
                'OutputSignals',opOutSignals,...
                'EMLFileName',ipf,...
                'EMLParams',bmp,...
                'BlockComment',stageComment,...
                'EMLFlag_RunLoopUnrolling',true,...
                'EMLFlag_ParamsFollowInputs',false);
            end


            inputLenOdd=mod(inputLen,2)==1;
            if inputLenOdd
                pirelab.getDTCComp(hN,hInSignals(end),hOutSignals(end),rndMode,satMode);
            end
        end
        return;

    elseif strcmpi(opName,'min')

        if strcmpi(minmaxOutMode,'Value')
            ipf='hdleml_min_vector';
            hInSignals=structSignalsIn.tSignals;
            hOutSignals=structSignalsOut.tSignals;

        elseif strcmpi(minmaxOutMode,'Value and Index')
            ipf='hdleml_min_vector_valandidx';
            hInSignals=[structSignalsIn.tSignals,structSignalsIn.tIndex];
            hOutSignals=[structSignalsOut.tSignals,structSignalsOut.tIndex];

        else
            if stageNum==numStages

                ipf='hdleml_min_vector_idxonly';
                hInSignals=[structSignalsIn.tSignals,structSignalsIn.tIndex];
                hOutSignals=structSignalsOut.tIndex;
            else
                ipf='hdleml_min_vector_valandidx';
                hInSignals=[structSignalsIn.tSignals,structSignalsIn.tIndex];
                hOutSignals=[structSignalsOut.tSignals,structSignalsOut.tIndex];
            end
        end
        bmp={};

    elseif strcmpi(opName,'max')

        if strcmpi(minmaxOutMode,'Value')
            ipf='hdleml_max_vector';
            hInSignals=structSignalsIn.tSignals;
            hOutSignals=structSignalsOut.tSignals;

        elseif strcmpi(minmaxOutMode,'Value and Index')
            ipf='hdleml_max_vector_valandidx';
            hInSignals=[structSignalsIn.tSignals,structSignalsIn.tIndex];
            hOutSignals=[structSignalsOut.tSignals,structSignalsOut.tIndex];

        else
            if stageNum==numStages

                ipf='hdleml_max_vector_idxonly';
                hInSignals=[structSignalsIn.tSignals,structSignalsIn.tIndex];
                hOutSignals=structSignalsOut.tIndex;
            else
                ipf='hdleml_max_vector_valandidx';
                hInSignals=[structSignalsIn.tSignals,structSignalsIn.tIndex];
                hOutSignals=[structSignalsOut.tSignals,structSignalsOut.tIndex];

            end
        end
        bmp={};

    else
        error(message('hdlcoder:validate:treeunsupported',opName));
    end


    treeName=sprintf('---- Tree %s implementation ----',lower(opName));
    stageName=sprintf('%s_treestage%d',compName,stageNum);
    stageComment=sprintf('---- Tree %s stage %d ----',lower(opName),stageNum);
    if stageNum==1
        stageComment=sprintf('%s\n%s',treeName,stageComment);
    end


    treeComp=hN.addComponent2(...
    'kind','cgireml',...
    'Name',stageName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'EMLFileName',ipf,...
    'EMLParams',bmp,...
    'BlockComment',stageComment,...
    'EMLFlag_RunLoopUnrolling',true);

end



function structSignalsIn=getStageInputSignal(hN,muxOutSignal,opName,hOutSignals,minmaxIdxBase,minmaxOutMode)

    if strcmpi(opName,'sum')
        structSignalsIn.tSignals=muxOutSignal;

    elseif strcmpi(opName,'product')
        structSignalsIn.tSignals=muxOutSignal;
        structSignalsIn.tReach128=false(pirelab.getVectorTypeInfo(muxOutSignal),1);

    elseif strcmpi(opName,'min')||strcmpi(opName,'max')

        if strcmpi(minmaxOutMode,'Value')
            structSignalsIn.tSignals=muxOutSignal;

        else
            structSignalsIn.tSignals=muxOutSignal;


            if strcmpi(minmaxOutMode,'Value and Index')
                indexType=hOutSignals(2).Type.getLeafType;
            else
                indexType=hOutSignals(1).Type.getLeafType;
            end
            dimLen=pirelab.getVectorTypeInfo(muxOutSignal);
            constIndexSignals=getIndexConstantComp(hN,dimLen,minmaxIdxBase,indexType,muxOutSignal.SimulinkRate);
            structSignalsIn.tIndex=constIndexSignals;
        end

    else
        error(message('hdlcoder:validate:treeunsupported',opName));
    end

end


function[structSignalsOut,outTypeEx]=getStageOutputSignal(hN,opName,compName,stageNum,structSignalsIn,hOutSignals,numStages,minmaxOutMode,rndMode,satMode)


    inputLen=pirelab.getInputDimension(structSignalsIn.tSignals);


    stageLen=ceil(inputLen/2);

    if strcmpi(opName,'sum')
        if(pirelab.hasComplexType(structSignalsIn.tSignals.Type))
            tInType=pirelab.getComplexType(structSignalsIn.tSignals.Type);
        else
            tInType=structSignalsIn.tSignals.Type.getLeafType;
        end

        tOutType=hdlarch.tree.getStageOutputType(tInType,opName);

        outTypeEx=pirelab.getTypeInfoAsFi(tOutType,rndMode,satMode);

        structSignalsOut.tSignals=getOneStageOutputSignal(hN,tOutType,stageLen,compName,stageNum);

    elseif strcmpi(opName,'min')||strcmpi(opName,'max')

        tInType=structSignalsIn.tSignals.Type.getLeafType;

        if~(strcmpi(minmaxOutMode,'Index')&&stageNum==numStages)

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

        outTypeEx=0;

    elseif strcmpi(opName,'product')
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

        if stageNum==1
            stageReach128=false;


            if(complex_mode)
                cInType=pirelab.getComplexType(tSignalsIn.Type);
                tInType=cInType.getLeafType;
            else
                tInType=tSignalsIn.Type.getLeafType;
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

            if(complex_mode)
                tOutType=pir_complex_t(tOutType);
            end


            if(pirelab.hasComplexType(tOutType))
                outTypeEx=pirelab.getTypeInfoAsFi(pirelab.getComplexType(tOutType),rndMode,satMode,1);
            else
                outTypeEx=pirelab.getTypeInfoAsFi(tOutType,rndMode,satMode);
            end
            if(complex_mode)
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
            outTypeEx=cell(opLen,1);


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


                outTypeEx{ii}=pirelab.getTypeInfoAsFi(tOutType,rndMode,satMode);

                if(complex_mode)
                    if(tInType1.isDoubleType)
                        outTypeEx{ii}=outTypeEx{ii}+1i;
                    else
                        outTypeEx{ii}=fi(outTypeEx{ii}+1i,numerictype(outTypeEx{ii}));
                    end
                    tOutType=pir_complex_t(tOutType);
                end

                toutName=sprintf('%s_stage%d_%d',compName,stageNum,ii);
                tSignalsOut(ii)=hN.addSignal(tOutType,toutName);
            end


            inputLenOdd=mod(inputLen,2)==1;
            if inputLenOdd
                toutName=sprintf('%s_stage%d_%d',compName,stageNum,stageLen);
                if(pirelab.hasComplexType(tSignalsIn(end).Type))
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
        error(message('hdlcoder:validate:treeunsupported',opName));
    end

end


function tSignalsOut=getOneStageOutputSignal(hN,tOutType,stageLen,compName,stageNum,appendStr)

    if nargin<6
        appendStr='';
    end

    if stageLen>1
        treeStageType=pirelab.getPirVectorType(tOutType,stageLen);
    else
        treeStageType=tOutType;
    end
    toutName=sprintf('%s_stage%d%s',compName,stageNum,appendStr);
    tSignalsOut=hN.addSignal(treeStageType,toutName);

end


function muxOutSignal=getMuxComp(hN,hInSignals,compName)
    if length(hInSignals)>1
        muxOutType=pirelab.getPirVectorType(hInSignals(1).Type,length(hInSignals));
        muxOutSignal=hN.addSignal(muxOutType,sprintf('%s_muxout',compName));
        pirelab.getMuxComp(hN,hInSignals,muxOutSignal,sprintf('%s_muxcomp',compName));
    else
        muxOutSignal=hInSignals;
    end
end



function constIndexSignals=getIndexConstantComp(hN,dimLen,idxBase,indexType,slRate)


    indexName=sprintf('const_idx');


    for ii=1:dimLen
        if strcmp(idxBase,'One')
            constValue(ii)=ii;%#ok<AGROW>
        else
            constValue(ii)=ii-1;%#ok<AGROW>
        end
    end


    if dimLen>1
        constType=pirelab.getPirVectorType(indexType,dimLen);
    else
        constType=indexType;
    end
    constIndexSignals=hN.addSignal(constType,indexName);


    pirelab.getConstComp(hN,constIndexSignals,constValue);
    constIndexSignals.SimulinkRate=slRate;

end



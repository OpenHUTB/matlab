function cgirComp=getBitwiseOpComp(hN,hSignalsIn,hSignalsOut,opName,compName,useBitMask,bitMask)











    if(nargin<7)||isempty(bitMask)
        bitMask=0;
    end

    if(nargin<6)||isempty(useBitMask)
        useBitMask=false;
    end

    if(nargin<5)||isempty(compName)
        compName=opName;
    end


    opName=upper(opName);


    if strcmp(opName,'NOT')||(length(hSignalsIn)>1)
        cgirComp=createBitwiseOp(hN,hSignalsIn,hSignalsOut,opName,compName);
    elseif useBitMask


        hKonstSignal=hN.addSignal(hSignalsOut(1).Type,sprintf('bitMask_for_%s',compName));
        pireml.getConstComp(hN,hKonstSignal,bitMask,sprintf('bitMaskConstant_for_%s',compName));
        hSignalsIn(2)=hKonstSignal;

        cgirComp=createBitwiseOp(hN,hSignalsIn,hSignalsOut,opName,compName);
    else


        [dimlen,~]=pirelab.getVectorTypeInfo(hSignalsIn(1));

        if(dimlen>1)
            demuxComp=pireml.getDemuxCompOnInput(hN,hSignalsIn(1));
            cgirComp=createBitwiseOp(hN,demuxComp.PirOutputSignals,hSignalsOut,opName,compName);
        elseif(negatedOp(opName))
            cgirComp=createBitwiseOp(hN,hSignalsIn,hSignalsOut,'NOT',compName);
        else
            cgirComp=pirelab.getWireComp(hN,hSignalsIn,hSignalsOut,compName);
        end
    end

end



function retval=negatedOp(op)
    retval=strcmp(op,'NOT')||strcmp(op,'NAND')||strcmp(op,'NOR');
end




function cgirComp=createBitwiseOp(hN,hSignalsIn,hSignalsOut,opMode,compName)

    switch opMode
    case 'AND'
        emlFile='hdleml_bitand';
    case 'OR'
        emlFile='hdleml_bitor';
    case 'NAND'
        emlFile='hdleml_bitnand';
    case 'NOR'
        emlFile='hdleml_bitnor';
    case 'XOR'
        emlFile='hdleml_bitxor';
    case 'NOT'
        emlFile='hdleml_bitnot';
    end

    haveScalar=false;
    haveVector=false;
    vectorDim=1;
    isRowVector=0;
    for ii=1:length(hSignalsIn)
        sigDim=hSignalsIn(ii).Type.getDimensions;
        if haveScalar==false&&sigDim==1
            haveScalar=true;
            continue;
        end
        if haveVector==false&&sigDim>1
            haveVector=true;
            vectorDim=sigDim;
            isRowVector=hSignalsIn(ii).Type.isRowVector;
        end
    end
    if haveVector&&haveScalar

        for ii=1:length(hSignalsIn)
            sigDim=hSignalsIn(ii).Type.getDimensions;
            if sigDim==1

                hSignalsIn(ii)=pirelab.scalarExpand(hN,hSignalsIn(ii),...
                vectorDim,isRowVector);
            end
        end
    end


    cgirComp=hN.addComponent2('kind','cgireml',...
    'Name',compName,...
    'InputSignals',hSignalsIn,...
    'OutputSignals',hSignalsOut,...
    'EMLFileName',emlFile,...
    'EMLFlag_ParamsFollowInputs',false,...
    'EMLParams',{},...
    'EMLFlag_RunLoopUnrolling',false);
end



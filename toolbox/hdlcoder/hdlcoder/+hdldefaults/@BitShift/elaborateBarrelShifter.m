function hNewC=elaborateBarrelShifter(this,hN,hC)



    hOutSignals=hC.PirOutputSignals;
    hInSignals=hC.PirInputSignals;


    in_vector_mode=hC.PirInputSignals(1).Type.isArrayType;

    if hN.optimizationsRequested
        if(in_vector_mode)
            sig_serialized=pirelab.getDemuxCompOnInput(hN,hInSignals(1));

            tmp_sig_out=[];
            for itr=1:length(sig_serialized.PirOutputSignals)
                tmp_sig_out=[tmp_sig_out,hN.addSignal(hOutSignals.Type.getLeafType,sprintf('out_%d',itr))];%#ok<AGROW>

                elaborate_inline(this,hN,hC,[sig_serialized.PirOutputSignals(itr),hInSignals(2)],tmp_sig_out(end),...
                sig_serialized.PirOutputSignals(itr).Type,hInSignals(2).Type,tmp_sig_out(end).Type);
            end

            hNewC=pirelab.getMuxComp(hN,tmp_sig_out,hOutSignals);
        else
            sig_in=hC.PirInputSignals(1);
            sig_out=hC.PirOutputSignals;

            hNewC=elaborate_inline(this,hN,hC,[sig_in,hC.PirInputSignals(2)],sig_out,...
            sig_in.Type,hC.PirInputSignal(2).Type,sig_out.Type);
        end

    else
        architecture='barrel';
        nwName='BarrelShifter';
        if~isempty(hC.Name)
            nwName=hC.Name;
        end

        hNew=pirelab.createNewNetwork(...
        'Network',hN,...
        'Name',nwName,...
        'InportNames',{'in1','in2'},...
        'InportTypes',[hInSignals(1).Type,hInSignals(2).Type],...
        'InportRates',[hInSignals(1).SimulinkRate,hInSignals(2).SimulinkRate],...
        'OutportNames',{'out1'},...
        'OutportTypes',[hOutSignals(1).Type]);

        hInSignals_newnet=hNew.PirInputSignals;
        hOutSignals_newnet=hNew.PirOutputSignals;

        if(in_vector_mode)
            sig_serialized=pirelab.getDemuxCompOnInput(hNew,hInSignals_newnet(1));

            tmp_sig_out=[];
            for itr=1:length(sig_serialized.PirOutputSignals)
                tmp_sig_out=[tmp_sig_out,hNew.addSignal(hOutSignals_newnet.Type.getLeafType,sprintf('out_%d',itr))];%#ok<AGROW>

                elaborate_inline(this,hNew,hC,[sig_serialized.PirOutputSignals(itr),hInSignals_newnet(2)],tmp_sig_out(end),...
                sig_serialized.PirOutputSignals(itr).Type,hInSignals_newnet(2).Type,tmp_sig_out(end).Type);
            end

            pirelab.getMuxComp(hNew,tmp_sig_out,hOutSignals_newnet);
        else
            sig_in=hInSignals_newnet(1);
            sig_out=hOutSignals_newnet(1);

            elaborate_inline(this,hNew,hC,[sig_in,hInSignals_newnet(2)],sig_out,...
            sig_in.Type,hInSignals_newnet(2).Type,sig_out.Type);
        end


        hNewC=pirelab.instantiateNetwork(hN,hNew,hInSignals,hOutSignals,[architecture,'_inst']);
        hNew.generateModelFromPir();
    end

    return
end



function hNewC=elaborate_inline(this,hN,hC,hInSignals,hOutSignals,inType,shiftType,outType,mode)%#ok<INUSD>
    blkInfo=this.getBlockInfo(hC);
    inType=inType.getLeafType;
    sel=hInSignals(2);
    N=inType.WordLength-1;
    switch lower(blkInfo.shiftDirection)
    case 'right'
        blkInfo.isLeft=false;
        blkInfo.isRight=true;
        S_perms=right_shift_permutations(N);
    case 'left'
        blkInfo.isLeft=true;
        blkInfo.isRight=false;
        S_perms=left_shift_permutations(N);
    case 'bidirectional'
        if(~shiftType.Signed)


            blkInfo.isLeft=false;
            blkInfo.isRight=true;
            S_perms=right_shift_permutations(N);
        else
            blkInfo.isLeft=true;
            blkInfo.isRight=true;
            R_perms=right_shift_permutations(N);
            L_perms=left_shift_permutations(N);
            bidiSig=pirelab.getCompareToZero(hN,sel,'<','bidi_shift');


            selType=sel.Type.getLeafType;
            absSel=hN.addSignal(pir_ufixpt_t(selType.WordLength+1,selType.FractionLength),'abs_sig');
            pirelab.getAbsComp(hN,hInSignals(2),absSel,'floor','wrap','abs_sel');


            sel=absSel;
        end
    otherwise

        error(message('hdlcoder:validate:unsupportedBitshiftBinPt'));
    end

    isBidirectional=(blkInfo.isRight&&blkInfo.isLeft);

    tmpSig(1)=hN.addSignal(pir_ufixpt_t(inType.WordLength,0),'shift_sig');
    tmpSig(2)=hN.addSignal(pir_ufixpt_t(inType.WordLength,0),'input_sig');
    tmpSig(3)=hN.addSignal(pir_ufixpt_t(inType.WordLength,0),'o_concat_sig');




    pirelab.getDTCComp(hN,hInSignals(1),tmpSig(1),'floor','wrap','SI');
    pirelab.getDTCComp(hN,sel,tmpSig(2),'floor','wrap','SI');


    for itr=1:(N+1)
        tmpSlice(itr)=hN.addSignal(pir_ufixpt_t(1,0),['bit_',num2str(N-(itr-1))]);%#ok<AGROW>
        pirelab.getBitSliceComp(hN,hInSignals(1),tmpSlice(itr),N-(itr-1),N-(itr-1));
    end


    for itr=1:N+1
        muxOutSig(itr)=hN.addSignal(pir_ufixpt_t(1,0),['o_mux',num2str(itr-1)]);%#ok<AGROW>
    end

    if~(blkInfo.isRight&&inType.Signed)||isBidirectional
        zeroSig=hN.addSignal(pir_ufixpt_t(1,0),'zero_sig');
        pirelab.getConstComp(hN,zeroSig,uint8(0));
    end

    function nxt_signal=getNextSignal(P_perms,muxno,c)

        idx=P_perms(1+c,1+muxno);
        if idx<0
            if~(blkInfo.isRight&&inType.Signed)
                nxt_signal=zeroSig;
            else
                nxt_signal=tmpSlice(1);
            end
        else
            nxt_signal=tmpSlice(1+idx);
        end
    end


    for muxno=0:(N)

        permSignalIn=[];
        for c=0:N
            if isBidirectional

                right_signal=getNextSignal(R_perms,muxno,c);
                left_signal=getNextSignal(L_perms,muxno,c);
                nxt_signal=hN.addSignal(left_signal.Type,sprintf('sigLR%d_%d',muxno,c));
                pirelab.getSwitchComp(hN,[right_signal,left_signal],nxt_signal,bidiSig,['LR_',num2str(muxno)]);
            else
                nxt_signal=getNextSignal(S_perms,muxno,c);
            end

            permSignalIn=[permSignalIn(:);nxt_signal];
        end

        pirelab.getMultiPortSwitchComp(hN,[sel;permSignalIn],muxOutSig(muxno+1),1,...
        'Zero-based contiguous','floor','wrap',['Mux',num2str(muxno)]);
    end


    pirelab.getBitConcatComp(hN,muxOutSig,tmpSig(3));





    hNewC=pirelab.getDTCComp(hN,tmpSig(3),hOutSignals(1),'floor','wrap','SI');
    return
end


function RS_perms=right_shift_permutations(N)
    RS_perms=toeplitz([0,fliplr(1:N)]',0:N);


    RS_perms=triu(RS_perms);
    RS_perms=RS_perms+tril(-1*ones(1+N))+eye(N+1);
end

function LS_perms=left_shift_permutations(N)
    LS_perms=hankel(0:N,([N,0:(N-1)]'));


    sub=tril(-1*ones(1+N));
    sub(([1:(1+N)]-1)*(1+N)+[1:(1+N)])=0;%#ok<NBRAK>

    LS_perms=fliplr(triu(fliplr(LS_perms))+sub);
end

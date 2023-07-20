function v=validateBlock(this,hC)




    v=hdlvalidatestruct;

    dinType=hC.PirInputSignals(1).Type;
    dinBType=dinType.getLeafType;
    blockInfo=getBlockInfo(this,hC);















    t=blockInfo.trellis;
    k=blockInfo.k;
    n=blockInfo.n;
    L=blockInfo.L;
    nS=t.numStates;


    checkStateMetric=true;

    checkInOutDim=true;




    if(k>1)
        v(end+1)=hdlvalidatestruct(1,...
        message('comm:hdl:ViterbiDecoder:validateBlock:coderate'));
        checkStateMetric=false;
        checkInOutDim=false;
    else


        nextS=t.nextStates;
        reqnextS=[floor(([1:nS]-1)/2);floor(([1:nS]-1)/2)+nS/2]';%#ok
        cs=(reqnextS==nextS);
        isforward=(sum(sum(cs(:,:)))==nS*2);
        if(~isforward)
            v(end+1)=hdlvalidatestruct(1,...
            message('comm:hdl:ViterbiDecoder:validateBlock:nonrecursivetrellis'));
            checkStateMetric=false;
            checkInOutDim=false;
        end
    end

    if(n<2)||(n>7)
        v(end+1)=hdlvalidatestruct(1,...
        message('comm:hdl:ViterbiDecoder:validateBlock:coderate'));
        checkStateMetric=false;
        checkInOutDim=false;
    end

    if(L<3)||(L>9)
        v(end+1)=hdlvalidatestruct(1,...
        message('comm:hdl:ViterbiDecoder:validateBlock:constraintlength'));
        checkStateMetric=false;
        checkInOutDim=false;
    end





    if(dinBType.isDoubleType||dinBType.isSingleType)
        v(end+1)=hdlvalidatestruct(1,...
        message('comm:hdl:ViterbiDecoder:validateBlock:DSinputnotsupport'));
    else

        if(~(dinBType.isUnsignedType||dinBType.isBooleanType))
            v(end+1)=hdlvalidatestruct(1,...
            message('comm:hdl:ViterbiDecoder:validateBlock:signedinputnotsupport'));
        elseif(dinBType.Wordlength~=blockInfo.nsDec)
            v(end+1)=hdlvalidatestruct(1,...
            message('comm:hdl:ViterbiDecoder:validateBlock:onlysupportUfixN'));
        end
    end

    if(blockInfo.nsDec==0)
        checkStateMetric=false;
        v(end+1)=hdlvalidatestruct(1,...
        message('comm:hdl:ViterbiDecoder:validateBlock:Dectypenotsupport'));
    end



    if(checkStateMetric)
        [~,~,stmetNT]=renormparam(this,t,blockInfo.nsDec);
        opstmetWL=stmetNT.WordLength;
        blocksmWL=blockInfo.smwl;

        if(opstmetWL<blocksmWL)
            v(end+1)=hdlvalidatestruct(3,...
            message('comm:hdl:ViterbiDecoder:validateBlock:replacestmetWL',opstmetWL));
        elseif(opstmetWL>blocksmWL)

            v(end+1)=hdlvalidatestruct(1,...
            message('comm:hdl:ViterbiDecoder:validateBlock:stmetWLtoosmall',opstmetWL));
        end


    end


    if(checkInOutDim)



        msg=dsphdlshared.validation.getMultiSymbolValidationMessage(...
        hC.PirInputSignals(1),n);

        v(end+1)=baseValidateVectorPortLength(this,hC.PirInputSignals(1),...
        n,msg);
    end


    if~strcmpi(blockInfo.reset,'off')
        v(end+1)=hdlvalidatestruct(1,...
        message('comm:hdl:ViterbiDecoderRam:validateBlock:resetunsupport'));
    end

    if~strcmpi(blockInfo.erasures,'off')
        v(end+1)=hdlvalidatestruct(1,...
        message('comm:hdl:ViterbiDecoder:validateBlock:erasureunsupported'));
    end






    v(end+1)=hdlvalidatestruct(3,...
    message('comm:hdl:ViterbiDecoder:validateBlock:latencyinfo',blockInfo.latency));




    if(blockInfo.tbd<L)
        v(end+1)=hdlvalidatestruct(1,...
        message('comm:hdl:ViterbiDecoder:validateBlock:tbdtoosmall'));
    end

    if(blockInfo.tbd<(10*L))
        v(end+1)=hdlvalidatestruct(3,...
        message('comm:hdl:ViterbiDecoderRam:validateBlock:tbdtoosmallforram'));
    end

    if strfind(blockInfo.opmode,'Truncated')

        v(end+1)=hdlvalidatestruct(1,...
        message('comm:hdl:ViterbiDecoder:validateBlock:truncatedmode'));
    end

    if strfind(blockInfo.opmode,'Terminate')

        v(end+1)=hdlvalidatestruct(1,...
        message('comm:hdl:ViterbiDecoder:validateBlock:terminatedmode'));
    end


end

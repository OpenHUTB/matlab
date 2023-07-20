function v=validateBlock(this,hC)





    v=hdlvalidatestruct;

    if isa(hC,'hdlcoder.sysobj_comp')
        sysObjHandle=hC.getSysObjImpl;
        blockInfo=getSysObjInfo(this,sysObjHandle);
    else
        blockInfo=getBlockInfo(this,hC);
    end

    insignals=hC.PirInputSignals;
    dinType=insignals(1).Type;
    dinBType=dinType.getLeafType;















    t=blockInfo.trellis;
    k=blockInfo.k;
    n=blockInfo.n;
    L=blockInfo.L;
    nS=t.numStates;


    checkStateMetric=true;

    checkInOutDim=true;

    validTbPipeImplParam=true;

    tbpipevalue=this.getImplParams('TracebackStagesPerPipeline');
    tbd=blockInfo.tbd;
    if~isa(hC,'hdlcoder.sysobj_comp')
        blkName=get_param(hC.SimulinkHandle,'Name');
    else
        blkName='(System Object)';
    end
    v(end+1)=hdlvalidatestruct(3,message('hdlcoder:validate:LatencyMismatch',blkName));
    v(end+1)=hdlvalidatestruct(3,message('hdlcoder:validate:NumericsMismatch',blkName));


    if~isempty(tbpipevalue)
        if~isnumeric(tbpipevalue)||any(double(tbpipevalue)<0)||...
            any(double(tbpipevalue)~=floor(double(tbpipevalue)))

            validTbPipeImplParam=false;
        elseif any(double(tbpipevalue)==0)
            v(end+1)=hdlvalidatestruct(1,...
            message('comm:hdl:ViterbiDecoder:validateBlock:noninteger'));
            validTbPipeImplParam=false;
        elseif any(double(tbpipevalue)>tbd)
            v(end+1)=hdlvalidatestruct(3,...
            message('comm:hdl:ViterbiDecoder:validateBlock:toolarge'));
        end
    else
        v(end+1)=hdlvalidatestruct(3,...
        message('comm:hdl:ViterbiDecoder:validateBlock:defaultvalue'));

    end



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
        insignals(1),n);

        v(end+1)=baseValidateVectorPortLength(this,insignals(1),...
        n,msg);
    end


    if blockInfo.hasResetPort
        if length(insignals)>2
            resetType=insignals(3).Type;
        else
            resetType=insignals(2).Type;
        end
        if~(resetType.isBooleanType)
            v(end+1)=hdlvalidatestruct(1,...
            message('comm:hdl:ViterbiDecoder:validateBlock:resettypeunsupported'));
        end

        if~blockInfo.DelayedResetAction
            v(end+1)=hdlvalidatestruct(1,...
            message('comm:hdl:ViterbiDecoder:validateBlock:resetmodeunsupported'));
        end
    end



    if~strcmpi(blockInfo.erasures,'off')
        v(end+1)=hdlvalidatestruct(1,...
        message('comm:hdl:ViterbiDecoder:validateBlock:erasureunsupported'));
    end




    if validTbPipeImplParam

        v(end+1)=hdlvalidatestruct(3,...
        message('comm:hdl:ViterbiDecoder:validateBlock:latencyinfo',blockInfo.latency));
    end



    if(blockInfo.tbd<L)
        v(end+1)=hdlvalidatestruct(1,...
        message('comm:hdl:ViterbiDecoder:validateBlock:tbdtoosmall'));
    end

    if strfind(blockInfo.opmode,'Truncated')

        v(end+1)=hdlvalidatestruct(1,...
        'HDL support is not available for the Truncated operation mode',...
        'comm:hdl:ViterbiDecoder:validateBlock:truncatedmode');
    end

    if strfind(blockInfo.opmode,'Terminate')

        v(end+1)=hdlvalidatestruct(1,...
        message('comm:hdl:ViterbiDecoder:validateBlock:terminatedmode'));
    end


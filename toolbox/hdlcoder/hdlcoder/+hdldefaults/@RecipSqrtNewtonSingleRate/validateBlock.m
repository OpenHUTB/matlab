function v=validateBlock(this,hC)




    v=hdlvalidatestruct;
    bfp=hC.SimulinkHandle;
    functionName=get_param(bfp,'Function');
    algorithmType=get_param(bfp,'AlgorithmType');
    inType=hC.PirInputSignals(1).Type.getLeafType;
    isNFPMode=targetcodegen.targetCodeGenerationUtils.isNFPMode();

    blkName=get_param(hC.SimulinkHandle,'Name');
    if~isNFPMode||...
        (isNFPMode&&~inType.isFloatType())
        v(end+1)=hdlvalidatestruct(3,message('hdlcoder:validate:LatencyMismatch',blkName));
    end
    v(end+1)=hdlvalidatestruct(3,message('hdlcoder:validate:NumericsMismatch',blkName));
    v(end+1)=hdlvalidatestruct(3,message('hdlcoder:validate:ValidationNumericMismatch',blkName));

    if(~strcmpi(functionName,'rsqrt'))
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:rsqrtSRunsupportedfunc',functionName));

    elseif~strcmpi(algorithmType,'Newton-Raphson')
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:rsqrtSRunsupportedmode'));

    else
        if targetcodegen.targetCodeGenerationUtils.isAlteraMode()&&targetmapping.hasFloatingPointPort(hC)
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:rsqrtinvalidarch'));
        end
        inputs=hC.SLInputPorts;
        ins=inputs.Signal;
        intype=hdlsignalsizes(ins);
        outputs=hC.SLOutputPorts;
        outs=outputs.Signal;
        outtype=hdlsignalsizes(outs);

        invectsize=max(hdlsignalvector(ins));
        if(invectsize>1)
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:rsqrtvectorin'));
            return;
        end

        if(outtype(3)&&outtype(1)==0&&outtype(2)==0)||...
            (intype(3)&&intype(1)==0&&intype(2)==0)
            if isNFPMode
                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:nfpnewtonrsqrt'));
            else
                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:rsqrtnofixpout'));
            end
            return;
        end

        if(intype(3))
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:rsqrtsignedin'));
        end


        hInSignals=hC.PirInputSignals;
        hOutSignals=hC.PirOutputSignals;
        newtonInfo=getBlockInfo(this,bfp);
        intermType=hdlarch.newton.getNewtonRSqrtIntermType(hInSignals,hOutSignals,newtonInfo.intermDT,newtonInfo.internalRule);

        if hdlarch.newton.isNewtonRSqrtOverLimit(hInSignals,intermType)
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:rsqrtoverlimit'));
        end


        inputRate=hInSignals(1).SimulinkRate;
        if isequal(inputRate,Inf)
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:rsqrtInfInputRate'));
        end

    end






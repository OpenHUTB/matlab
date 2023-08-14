function v=validateBlock(this,hC)




    v=hdlvalidatestruct;
    bfp=hC.SimulinkHandle;
    functionName=get_param(bfp,'Function');
    inType=hC.PirInputSignals(1).Type.getLeafType;
    isNFPMode=targetcodegen.targetCodeGenerationUtils.isNFPMode();

    blkName=get_param(hC.SimulinkHandle,'Name');

    if~isNFPMode||...
        (isNFPMode&&~inType.isFloatType())
        v(end+1)=hdlvalidatestruct(3,message('hdlcoder:validate:LatencyMismatch',blkName));
    end
    v(end+1)=hdlvalidatestruct(3,message('hdlcoder:validate:NumericsMismatch',blkName));
    v(end+1)=hdlvalidatestruct(3,message('hdlcoder:validate:ValidationNumericMismatch',blkName));

    if(~strcmpi(functionName,'sqrt'))
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:newtonsqrtunsupported',functionName));
    else
        if targetcodegen.targetCodeGenerationUtils.isAlteraMode()&&targetmapping.hasFloatingPointPort(hC)
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:newtonsqrtinvalidarch'));
        end
        inputs=hC.SLInputPorts;
        ins=inputs.Signal;
        intype=hdlsignalsizes(ins);
        outputs=hC.SLOutputPorts;
        outs=outputs.Signal;
        outtype=hdlsignalsizes(outs);

        invectsize=max(hdlsignalvector(ins));
        if(invectsize>1)
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:newtonsqrtvectorin'));
            return;
        end

        if(outtype(3)&&outtype(1)==0&&outtype(2)==0)||...
            (intype(3)&&intype(1)==0&&intype(2)==0)
            if isNFPMode
                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:nfpnewtonsqrt'));
            else
                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:newtonsqrtnofixpout'));
            end
            return;
        end

        if(intype(3))
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:newtonsqrtsignedin'));
        end


        hInSignals=hC.PirInputSignals;
        if hdlarch.newton.isNewtonSqrtOverLimit(hInSignals)
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:newtonrsqrtoverlimit'));
        end



        inputType=hInSignals(1).Type;
        inputWL=inputType.WordLength;
        if inputWL<4
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:newtonrsqrtunderlimit'));
        end


        inputRate=hInSignals(1).SimulinkRate;
        if isequal(inputRate,Inf)
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:newtonInfInputRate'));
        end

    end







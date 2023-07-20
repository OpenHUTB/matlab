function v=validateBlock(~,hC)


    v=hdlvalidatestruct;

    bfp=hC.SimulinkHandle;
    type=hdlgetblocklibpath(bfp);
    isMath=~isempty(strfind(type,'Math'));
    isProduct=~isempty(strfind(type,'Product'));
    sat=strcmp(get_param(bfp,'SaturateOnIntegerOverflow'),'on');
    rnd=get_param(bfp,'RndMeth');
    inType=hC.PirInputSignals(1).Type.getLeafType;
    isNFPMode=targetcodegen.targetCodeGenerationUtils.isNFPMode();

    blkName=get_param(bfp,'Name');
    if~isNFPMode||...
        (isNFPMode&&~inType.isFloatType())
        v(end+1)=hdlvalidatestruct(3,message('hdlcoder:validate:LatencyMismatch',blkName));
    end
    v(end+1)=hdlvalidatestruct(3,message('hdlcoder:validate:NumericsMismatch',blkName));
    v(end+1)=hdlvalidatestruct(3,message('hdlcoder:validate:ValidationNumericMismatch',blkName));

    if(isMath)
        functionName=get_param(bfp,'Function');
    elseif(isProduct)
        inputsigns=get_param(bfp,'Inputs');
        inputsigns=strrep(inputsigns,'|','');

        functionName='Product';
        if~isempty(strfind(inputsigns,'/'))
            if length(hC.SLInputPorts)==1
                in1signal=hC.SLInputPorts(1).Signal;

                if(hdlsignaliscomplex(in1signal)==1)
                    v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:unsupportcomplexdivide'));
                else
                    functionName='Reciprocal';
                end
            end
        end
    end


    if(~strcmpi(functionName,'Reciprocal'))
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:recipunsupported',functionName));
    else
        if targetcodegen.targetCodeGenerationUtils.isAlteraMode()&&targetmapping.hasFloatingPointPort(hC)
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:invalidarch'));
        end
        inputs=hC.SLInputPorts;
        ins=inputs.Signal;
        intype=hdlsignalsizes(ins);
        outputs=hC.SLOutputPorts;
        outs=outputs.Signal;
        outtype=hdlsignalsizes(outs);

        invectsize=max(hdlsignalvector(ins));
        if(invectsize>1)
            if isProduct
                if isFloatType(hC.PirInputSignals.Type.BaseType)
                    v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:recipvectorinpoefloat'));
                else
                    v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:recipvectorinpoefixed'));
                end
            elseif isMath
                if isFloatType(hC.PirInputSignals.Type.BaseType)
                    v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:recipvectorinmathfloat'));
                else
                    v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:recipvectorinmathfixed'));
                end
            else
                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:recipvectorin'));
            end
            return;
        end

        if(~strcmpi(rnd,'zero'))
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:recipRnd'));
        end

        if(~sat)
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:recipsat'));
        end

        if(outtype(3)&&outtype(1)==0&&outtype(2)==0)||...
            (intype(3)&&intype(1)==0&&intype(2)==0)
            if isMath
                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:recipnofixpoutmath'));
            elseif isProduct
                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:recipnofixpoutprod'));
            else
                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:recipnofixpout'));
            end
            return;
        end


        hInSignals=hC.PirInputSignals;
        if hdlarch.newton.isNewtonSqrtOverLimit(hInSignals)
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:reciprsqrtbasedoverlimit','ReciprocalRsqrtBasedNewton'));
        end



        inputType=hInSignals(1).Type;
        inputWL=inputType.WordLength;
        if inputWL==3
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:recipminwordlen'));
        end


        inputRate=hInSignals(1).SimulinkRate;
        if isequal(inputRate,Inf)
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:RecipNewtonInfRate'));
        end
    end



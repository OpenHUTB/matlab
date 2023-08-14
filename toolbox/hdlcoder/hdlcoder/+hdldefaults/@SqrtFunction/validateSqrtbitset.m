function v=validateSqrtbitset(this,hC)



    bfp=hC.SimulinkHandle;
    sqrtInfo=this.getBlockInfo(bfp);
    rnd=sqrtInfo.rndMode;
    v=this.baseValidate(hC);
    in=hC.PirInputPorts(1).Signal;
    out=hC.PirOutputPorts(1).Signal;
    inBaseType=getPirSignalBaseType(hC.PirInputSignals(1).Type);
    outBaseType=getPirSignalBaseType(hC.PirOutputSignals(1).Type);

    intermediateType=get_param(bfp,'IntermediateResultsDataTypeStr');
    if(~targetmapping.hasFloatingPointPort(hC))
        if(strcmpi(rnd,'Convergent')||strcmpi(rnd,'Round'))
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:sqrtRnd',rnd));
        end
        if(~(strcmpi(intermediateType,'Inherit: Inherit via internal rule')))
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:validate:unsupportedIntermediateResultstype',hC.Name));
            return;
        end
        outSigned=outBaseType.Signed;
        outputWL=outBaseType.WordLength;
        outputFL=-outBaseType.FractionLength;
        inputWL=inBaseType.WordLength;
        inputFL=-inBaseType.FractionLength;
        if(strcmpi(rnd,'Nearest')&&(inputFL~=0&&outputFL==0))
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:sqrtNearestRnd'));
        end

        if outSigned
            k=outputWL-1;
        else
            k=outputWL;
        end


        if strcmpi(sqrtInfo.algorithm,'UseMultiplier')
            algorithmMultOn=true;

        else
            algorithmMultOn=false;
        end

        if(~algorithmMultOn)
            inputIntL=inputWL-inputFL;
            outputIntL=ceil(inputIntL/2);
            newoutWL=outputIntL+outputFL;
            k=min(k,newoutWL);
        end
        if(strcmpi(sqrtInfo.latencyStrategy,'CUSTOM'))
            totalPipelinestages=k+2;
            if(sqrtInfo.customLatency>totalPipelinestages)
                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:fixedpointAddShiftCustomLatencyError',num2str(sqrtInfo.customLatency),hC.Name,num2str(totalPipelinestages),num2str(outputWL)));
            end
        end
    elseif(~((targetmapping.hasComplexType(in.Type))...
        ||(targetmapping.hasComplexType(out.Type))))
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:TargetCodeGenInvalidSqrt'));
    end

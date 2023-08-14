function v=validateBlock(this,hC)%#ok<INUSL>




    v=hdlvalidatestruct;


    if isa(hC,'hdlcoder.sysobj_comp')
        [inMATLAB,~]=hdlismatlabmode();
        inputType=hC.PirInputSignals(1).Type;
        if inputType.isArrayType()
            if inputType.NumberOfDimensions()>1

                hImpl=hC.getSysObjImpl;
                fcn=['cordic',hImpl.FunctionName];

                if(inMATLAB)
                    [~,mlCfg]=hdlismatlabmode();
                    error(message('hdlcoder:validate:UnsupportedMatrixTypeMATLAB',fcn,mlCfg.DesignFunctionName));
                else

                    hDrv=hdlcurrentdriver();

                    error(message('hdlcoder:validate:UnsupportedMatrixTypeMLFcnBlk',fcn,hDrv.getEntityTop()));
                end
            end
            inputType=inputType.BaseType();
        end

        if(inputType.isFloatType()||~inputType.Signed)
            error(message('hdlcommon:hdlcommon:InputTypeMustBeSigned'));
        end

        return
    end


    bfp=hC.SimulinkHandle;
    blkName=get_param(bfp,'Name');
    blkName=regexprep(blkName,'\n',' ');
    inType=hC.PirInputSignals(1).Type.getLeafType;
    isNFPMode=targetcodegen.targetCodeGenerationUtils.isNFPMode();

    functionName=get_param(bfp,'Function');
    if~isNFPMode||...
        (isNFPMode&&~inType.isFloatType())
        if(~(isempty(this.getImplParams('UsePipelinedKernel'))))
            v(end+1)=hdlvalidatestruct(3,message('hdlcoder:validate:LatencyMismatch',blkName));
        end




        if~strcmpi(functionName,'atan2')
            v(end+1)=hdlvalidatestruct(3,message('hdlcoder:validate:ValidationNumericMismatch',blkName));
        end
    end


    dinType=hC.SLInputSignals(1).Type;

    if targetcodegen.targetCodeGenerationUtils.isAlteraMode()&&targetmapping.hasFloatingPointPort(hC)
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:invalidarchtrig'));
    end


    iterNum=this.hdlslResolve('NumberOfIterations',bfp);
    if(isempty(this.getImplParams('CustomLatency')))
        customLatency=0;
    else
        customLatency=this.getImplParams('CustomLatency');
    end

    if(isempty(this.getImplParams('LatencyStrategy')))
        latencyStrategy='MAX';
    else
        latencyStrategy=this.getImplParams('LatencyStrategy');
    end
    if(strcmpi(latencyStrategy,'CUSTOM'))
        if strcmpi(functionName,'atan2')
            totalPipelinestages=iterNum+3;
        else
            totalPipelinestages=iterNum+1;
        end
        if(customLatency>totalPipelinestages)
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:fixedpointCordicCustomLatencyError',num2str(customLatency),blkName,num2str(totalPipelinestages),num2str(iterNum)));
        end

    end
    in1BaseType=getPirSignalBaseType(hC.PirInputSignals(1).Type);
    if strcmpi(functionName,'atan2')
        maxSupportedWL=125;

        if(in1BaseType.WordLength>maxSupportedWL)
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:makehdl:wordlengthOverflowCordicComp',num2str(in1BaseType.WordLength),blkName,num2str(maxSupportedWL)));
        end
    else
        maxSupportedWL=126;
        if(in1BaseType.WordLength>maxSupportedWL)
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:makehdl:wordlengthOverflowCordicComp',num2str(dinType.BaseType.WordLength),blkName,num2str(maxSupportedWL-1)));
        end
    end
    switch functionName
    case{'sin','cos','sincos','cos + jsin','atan2'}
    otherwise
        if isNFPMode
            v(end+1)=hdlvalidatestruct(1,message('hdlcommon:nativefloatingpoint:trigfuncunsupported',functionName));
        else
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:trigfuncunsupported',functionName));
        end
    end


    if strcmpi(get_param(bfp,'ApproximationMethod'),'Lookup')
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:validate:useoptimizedTrig'));
    elseif~strcmpi(get_param(bfp,'ApproximationMethod'),'CORDIC')
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:validate:InvalidApproxMethod',blkName));
    end




    if in1BaseType.isFloatType
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:validate:UnsupportedDataTypeCORDIC'));
    elseif~in1BaseType.Signed&&strcmpi(get_param(bfp,'ApproximationMethod'),'CORDIC')
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcommon:hdlcommon:InputTypeMustBeSigned'));
    end




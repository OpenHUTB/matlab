function v=validateBlock(~,hC)








    bfp=hC.SimulinkHandle;

    approxMethod=get_param(bfp,'ApproximationMethod');

    validApproxNoneFunctions={...
    'sin',...
    'cos',...
    'atan2',...
    'sincos',...
    'cos + jsin',...
    };

    v=hdlvalidatestruct;

    in=hC.PirInputPorts(1).Signal;
    Fname=get_param(bfp,'Function');
    blkName=get_param(bfp,'Name');
    inType=hC.PirInputSignals(1).Type.getLeafType;
    isNFPMode=targetcodegen.targetCodeGenerationUtils.isNFPMode();

    if~isNFPMode||...
        (isNFPMode&&~inType.isFloatType())
        v(end+1)=hdlvalidatestruct(3,message('hdlcoder:validate:LatencyMismatchForArch',blkName,Fname));
    end
    v(end+1)=hdlvalidatestruct(3,message('hdlcoder:validate:NumericsMismatchForArch',blkName,Fname));

    if(targetcodegen.targetCodeGenerationUtils.isAlteraMode()...
        ||isNFPMode)...
        &&targetmapping.hasFloatingPointPort(hC)
        if~strcmpi(approxMethod,'None')&&any(strcmpi(validApproxNoneFunctions,Fname))


            if isNFPMode
                v(end+1)=hdlvalidatestruct(1,message('hdlcommon:nativefloatingpoint:trigApproxMethodNotNone'));
            else
                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:trigApproxMethodNotNone'));
            end
        end
    end


function v=validateBlock(~,hC)


    v=hdlvalidatestruct;
    nfpMode=targetcodegen.targetCodeGenerationUtils.isNFPMode;

    validApproxNoneFunctions={...
    'sin',...
    'cos',...
    'atan2',...
    'sincos',...
    'cos + jsin',...
    };

    if~targetcodegen.targetCodeGenerationUtils.isAlteraMode()&&~nfpMode
        assert(targetmapping.hasFloatingPointPort(hC));
        if nfpMode
            v(end+1)=hdlvalidatestruct(1,message('hdlcommon:nativefloatingpoint:TrigTargetInvalidarch'));
        else
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:TrigTargetInvalidarch'));
        end
    else
        bfp=hC.SimulinkHandle;
        approxMethod=get_param(bfp,'ApproximationMethod');
        Fname=get_param(bfp,'Function');
        if~strcmpi(approxMethod,'None')&&any(strcmpi(Fname,validApproxNoneFunctions))


            if nfpMode
                v(end+1)=hdlvalidatestruct(1,message('hdlcommon:nativefloatingpoint:trigApproxMethodNotNone'));
            else
                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:trigApproxMethodNotNone'));
            end
        end
        if strcmpi(Fname,'asin')||strcmpi(Fname,'acos')
            OutofRangeProtectionParam=get_param(bfp,'RemoveProtectionAgainstOutOfRangeInput');
            if(strcmpi(OutofRangeProtectionParam,'on'))
                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:removeProtectionAgainstOutofRangeInput'));
            end
        end
    end

    in1signal=hC.PirInputPorts(1).Signal;
    if(targetcodegen.targetCodeGenerationUtils.isAlteraMode()||targetcodegen.targetCodeGenerationUtils.isXilinxMode())&&in1signal.Type.isMatrix
        v=hdlvalidatestruct(1,...
        message('hdlcommon:targetcodegen:UnsupportedMatrixTypesTargetcodegen'));
    end



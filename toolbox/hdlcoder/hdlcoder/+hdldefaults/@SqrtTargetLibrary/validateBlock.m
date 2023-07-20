function v=validateBlock(this,hC)


    v=hdlvalidatestruct;

    if~targetcodegen.targetCodeGenerationUtils.isFloatingPointMode()
        assert(targetmapping.hasFloatingPointPort(hC));
        if(targetcodegen.targetCodeGenerationUtils.isNFPMode())
            v(end+1)=hdlvalidatestruct(1,message('hdlcommon:nativefloatingpoint:sqrtinvalidarch'));
        else
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:sqrtinvalidarch'));
        end
    else
        hInSignals=hC.PirInputSignals;
        hOutSignals=hC.PirOutputSignals;

        slbh=hC.SimulinkHandle;
        fname=get_param(slbh,'Function');



        isInputValidType=targetmapping.isValidDataType(getPirSignalBaseType(hInSignals(1).Type));
        isOutputValidType=targetmapping.isValidDataType(getPirSignalBaseType(hOutSignals(1).Type));
        if~isInputValidType||(~strcmp(fname,'signedSqrt')&&~isOutputValidType)
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:mixeddatatype'));
        end

        intermResDataType=get_param(slbh,'IntermediateResultsDataTypeStr');
        if(strcmpi(fname,'rSqrt'))&&(~(strcmp(intermResDataType,'double')))
            v(end+1)=hdlvalidatestruct(2,message('hdlcoder:validate:nfprsqrtIntermResDataType'));
        end



        nfpMode=targetcodegen.targetCodeGenerationUtils.isNFPMode();

        if nfpMode&&targetmapping.hasFloatingPointPort(hC)&&~strcmp(fname,'signedSqrt')
            if(~isequal(class(hInSignals(1).Type.getLeafType),class(hOutSignals(1).Type.getLeafType)))
                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:mixeddoubleUnhandled'));
            end
        end



        if nfpMode&&targetmapping.hasFloatingPointPort(hC)
            algorithmType=get_param(slbh,'AlgorithmType');
            if(strcmpi(fname,'rSqrt'))&&(strcmp(algorithmType,'Newton-Raphson'))
                v(end+1)=hdlvalidatestruct(1,message('hdlcommon:nativefloatingpoint:UnsupportedRsqrtAlgorithmMethod'));
            end
        end

        if nfpMode&&targetmapping.hasFloatingPointPort(hC)
            hInSignals=hC.PirInputSignals;
            hT=getPirSignalBaseType(hInSignals(1).Type);
            hLeafType=hT.getLeafType;
            if hLeafType.isSingleType
                dataType='SINGLE';
            elseif hLeafType.isHalfType
                dataType='HALF';
            else
                dataType='DOUBLE';
            end
            nfpOptions=getNFPBlockInfo(this);
            if nfpOptions.Latency==int8(4)
                fc=hdlgetparameter('FloatingPointTargetConfiguration');
                if strcmpi(fname,'rSqrt')
                    fcnName='Rsqrt';
                else
                    fcnName='Sqrt';
                end
                ipSettings=fc.IPConfig.getIPSettings(fcnName,dataType);
                if(ipSettings.CustomLatency>=0)&&(nfpOptions.Latency~=int8(4))
                    v(end+1)=hdlvalidatestruct(1,message('hdlcommon:nativefloatingpoint:NFPCustomLatencyLocalOptError',...
                    dataType,fcnName));
                end
                maxLatency=ipSettings.MaxLatency;
                if(nfpOptions.Latency==int8(4))&&(nfpOptions.CustomLatency>maxLatency)
                    v(end+1)=hdlvalidatestruct(1,message('hdlcommon:nativefloatingpoint:InvalidCustomLatencySpecified',...
                    hC.getBlockPath,num2str(maxLatency)));
                end
            end
        end
    end

    in1signal=hC.PirInputPorts(1).Signal;
    if(targetcodegen.targetCodeGenerationUtils.isAlteraMode()||targetcodegen.targetCodeGenerationUtils.isXilinxMode())&&in1signal.Type.isMatrix
        v=hdlvalidatestruct(1,...
        message('hdlcommon:targetcodegen:UnsupportedMatrixTypesTargetcodegen'));
    end



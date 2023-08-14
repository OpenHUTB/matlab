function v=validateBlock(this,hC)


    v=hdlvalidatestruct;
    slbh=hC.SimulinkHandle;


    if any(contains(get_param(slbh,'IndexOptionArray'),'port'))&&...
        ~strcmpi(get_param(slbh,'OutputInitialize'),'Initialize using input port <Y0>')
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:validate:OutputInitializeNotHandled'));
    end

    [~,numDims]=this.getBlockInfo(hC);
    numDims=str2double(numDims);
    hInT=hC.PIRInputSignals(1).Type;
    if~(hInT.isArrayType||...
        (hInT.isRecordType&&...
        (numel(hInT.MemberTypesFlattened)>1||hInT.MemberTypesFlattened.isArrayType)))

        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:validate:ScalarFirstInput'));
    end

    if hInT.isArrayOfRecords&&numel(hC.PIRInputSignals)>3


        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:validate:ArrayOfBus2DIndexing'));
    end

    if length(hC.PirInputPorts)>2
        controlPort=hC.PirInputPorts(3:end);
        for ii=1:length(controlPort)
            if targetmapping.mode(controlPort(ii).Signal)
                if targetcodegen.targetCodeGenerationUtils.isNFPMode()
                    v(end+1)=hdlvalidatestruct(2,...
                    message('hdlcommon:nativefloatingpoint:IndexVectorPortIsFlPtType'));
                else
                    v(end+1)=hdlvalidatestruct(1,...
                    message('hdlcoder:validate:IndexVectorPortIsFlPtType'));%#ok<*AGROW>
                end
                break;
            end
        end
    end

end

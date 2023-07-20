function v=validateBlock(this,hC)

    v=hdlvalidatestruct;


    out=hC.PirOutputPorts(1).Signal;
    out_iscmplx=hdlsignaliscomplex(out);


    in=hC.PirInputPorts(1).Signal;
    in_iscmplx=hdlsignaliscomplex(in);


    if~((in_iscmplx&&out_iscmplx)||...
        (~in_iscmplx&&~out_iscmplx))
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:mixedrealcomplex'));
    end

    numDims=this.getBlockInfo(hC);
    hInT=hC.PIRInputSignals(1).Type;


    if numDims>3
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:validate:SelectorDimensionError',...
        numDims));
    end

    if hInT.isArrayOfRecords&&numel(hC.PIRInputSignals)>2


        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:validate:ArrayOfBus2DIndexing'));
    end

    if numDims>2
        if any(contains(get_param(hC.SimulinkHandle,'IndexOptionArray'),'Starting index (port)'))


            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:validate:Unsupported3DSelectorStartIndexPort'));
        end
    end

    if length(hC.PirInputPorts)>1
        controlPort=hC.PirInputPorts(2:end);
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

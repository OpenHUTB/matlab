function v=validatePortDatatypes(this,hC)





    ports=this.getAllSLInputPorts(hC);


    ports=[ports,this.getAllSLOutputPorts(hC)];


    v=this.baseValidatePortDatatypes(ports);



    [rnd,sat,inputSigns,~,~,blockOptions]=this.getBlockInfo(hC);

    nfpMode=targetcodegen.targetCodeGenerationUtils.isNFPMode;
    out=hC.SLOutputSignals(1);
    in1signal=hC.PirInputSignals(1);
    outsignal=hC.PirOutputSignals(1);
    numInputPorts=hC.NumberOfPirInputPorts;



    if numInputPorts>2&&~(nfpMode&&targetmapping.mode(out)&&...
        inputSizesSupported(hC.PirInputSignals))
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:produnsupported'));
    end

    if nfpMode&&targetmapping.mode(out)
        return;
    end

    in1BaseType=getPirSignalBaseType(in1signal.Type);
    originalBlkPath=getfullname(hC.SimulinkHandle);
    outDataType=get_param(originalBlkPath,'OutDataTypeStr');

    if contains(inputSigns,'/')
        if numInputPorts==1
            if in1BaseType.isComplexType
                v(end+1)=hdlvalidatestruct(1,...
                message('hdlcoder:validate:produnsupportedcomplexdivide'));


            elseif((strcmpi(outDataType,'Inherit: Inherit via internal rule'))&&(max(hdlsignalvector(in1signal))==0))
                v(end+1)=hdlvalidatestruct(2,...
                message('hdlcoder:validate:useshiftaddArch'));

            end
        else
            in2signal=hC.PirInputPorts(2).Signal;
            in2BaseType=getPirSignalBaseType(in2signal.Type);
            if in1BaseType.isComplexType||in2BaseType.isComplexType
                v(end+1)=hdlvalidatestruct(1,...
                message('hdlcoder:validate:produnsupportedcomplexdivide'));
            else
                in1Sizes=hdlsignalsizes(in1signal);
                in2Sizes=hdlsignalsizes(in2signal);
                outSizes=hdlsignalsizes(outsignal);

                if(in1Sizes(2)-in2Sizes(2))~=outSizes(2)
                    v(end+1)=hdlvalidatestruct(1,...
                    message('hdlcoder:validate:produnsupportednonintdivide'));
                end

                checkTargetDivRound=isfield(get_param(bdroot,'ObjectParameters'),'TargetIntDivRoundTo');
                if~(strcmpi(rnd,'Zero')||(strcmpi(rnd,'Simplest')&&...
                    checkTargetDivRound&&~strcmpi(get_param(bdroot(getfullname(hC.SimulinkHandle)),...
                    'TargetIntDivRoundTo'),'Floor')))
                    v(end+1)=hdlvalidatestruct(1,...
                    message('hdlcoder:validate:produnsupportedrnd'));
                end

                if strcmpi(sat,'Wrap')
                    v(end+1)=hdlvalidatestruct(1,...
                    message('hdlcoder:validate:produnsupportedsat'));
                end
                outDim=outsignal.Type.getDimensions;

                if(blockOptions.firstInputSignDivide)
                    in1Dim=in2signal.Type.getDimensions;
                    in2Dim=in1signal.Type.getDimensions;
                else
                    in1Dim=in1signal.Type.getDimensions;
                    in2Dim=in2signal.Type.getDimensions;
                end




                if any(in1Dim~=outDim)||(any(in2Dim~=outDim)&&~isscalar(in2Dim))
                    v(end+1)=hdlvalidatestruct(1,...
                    message('hdlcoder:validate:prodmixedscalarvector'));
                end
                if((strcmpi(outDataType,'Inherit: Inherit via internal rule')))
                    v(end+1)=hdlvalidatestruct(2,...
                    message('hdlcoder:validate:useshiftaddArch'));

                end

            end
        end



    end




    outType=outsignal.Type.getLeafType;
    if numInputPorts==2&&~(outType.isFloatType)&&~outType.Signed&&outType.WordLength==128

        in2signal=hC.PirInputPorts(2).Signal;
        in1Type=in1signal.Type.getLeafType;
        in2Type=in2signal.Type.getLeafType;
        in1Len=in1Type.WordLength;
        in2Len=in2Type.WordLength;
        if(in1Len+in2Len>128)&&(in1Type.Signed||in2Type.Signed)

            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:unsupportedmult'));
        end
    end
end


function retval=inputSizesSupported(inputs)


    retval=true;
    first2scalars=~(inputs(1).Type.isArrayType||inputs(2).Type.isArrayType);
    if first2scalars
        for ii=3:numel(inputs)
            if inputs(ii).Type.isArrayType
                retval=false;
                break;
            end
        end
    end
end

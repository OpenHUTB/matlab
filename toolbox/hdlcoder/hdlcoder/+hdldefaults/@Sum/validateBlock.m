function v=validateBlock(this,hC)


    v=hdlvalidatestruct;
    bfp=hC.SimulinkHandle;

    [inputs,v,foundMatrix]=checkVectorInputs(hC,v);
    moreThan2Inputs=size(inputs,1)>2||(size(inputs,2)==1&&size(inputs,1)>2);

    if moreThan2Inputs
        if~inputSizesSupported(inputs)
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:suminputsdiffdimensions'));
        end
    end




    hN=hC.Owner;
    accumstr=get_param(bfp,'AccumDataTypeStr');
    nondefaultAccum=isempty(regexp(accumstr,'^Inherit: Inherit','once'));
    sat_on=strcmp(get_param(bfp,'SaturateOnIntegerOverflow'),'on');
    rnd_on=~strcmp(get_param(bfp,'RndMeth'),'Floor');
    if hN.getDistributedPipelining||hC.getConstrainedOutputPipeline>0
        if(sat_on||rnd_on)&&nondefaultAccum
            v(end+1)=hdlvalidatestruct(2,message('hdlcoder:validate:NonDefaultAccumTypePipelining'));
        end
    end




    out=hC.SLOutputSignals(1);
    opsizes=hdlsignalsizes(out);
    numInputPorts=hC.NumberOfPirInputPorts;

    if(foundMatrix&&numInputPorts==1)
        blkName=get_param(bfp,'Name');
        inType=hC.PirInputSignals(1).Type;
        outType=out.Type;
        ndims=inType.NumberOfDimensions;

        if(~inType.is2DMatrix&&outType.isArrayType)
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:matrix:toomanydimsforblock',...
            blkName,ndims,hC.PirInputSignals(1).Name));
        end
    end

    if targetmapping.mode(out)
        if numInputPorts>2
            if targetcodegen.targetCodeGenerationUtils.isNFPMode()

            else
                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:OnlyTwoInputsSupported'));
            end
        elseif numInputPorts==1
            if targetcodegen.targetCodeGenerationUtils.isNFPMode()

                v(end+1)=hdlvalidatestruct(3,message('hdlcommon:nativefloatingpoint:TreeArchHasLessLatency'));
            else


                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:OnlyTreeArchSupported'));
            end
        end

        nfpOptions=this.getNFPImplParamInfo;
        if nfpOptions.Latency~=int8(0)&&targetcodegen.targetCodeGenerationUtils.isNFPMode()
            out1=hC.PirOutputSignals;
            outType=out1.Type.getLeafType;
            if outType.isSingleType
                dataType='SINGLE';
            elseif outType.isHalfType
                dataType='HALF';
            else
                dataType='DOUBLE';
            end
            fc=hdlgetparameter('FloatingPointTargetConfiguration');
            ipSettings=fc.IPConfig.getIPSettings('AddSub',dataType);

            if(ipSettings.CustomLatency>=0)&&(nfpOptions.Latency~=int8(4))
                v(end+1)=hdlvalidatestruct(1,message('hdlcommon:nativefloatingpoint:NFPCustomLatencyLocalOptError',...
                dataType,'AddSub'));
            end
            if(nfpOptions.Latency==int8(4))&&(nfpOptions.CustomLatency>ipSettings.MaxLatency)
                v(end+1)=hdlvalidatestruct(1,message('hdlcommon:nativefloatingpoint:InvalidCustomLatencySpecified',...
                hC.getBlockPath,num2str(ipSettings.MaxLatency)));
            end
        end
    end
    try
        tmpdt=getaccumforsum(bfp,opsizes(1),opsizes(2),opsizes(3));
        if(tmpdt.size==0&&opsizes(1)>0)||(tmpdt.size>0&&opsizes(1)==0)




            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:mixeddoublesum'));
        end
    catch me
        v(end+1)=...
        hdlvalidatestruct(1,message('hdlcoder:validate:unsupportedaccumtype',me.message));
    end

    function[ins,v,foundMatrix]=checkVectorInputs(hC,v)

        foundMatrix=false;
        ninputs=hC.NumberOfPirInputPorts;
        vectlens=zeros(1,ninputs);
        for ii=1:ninputs
            inp=hC.PirInputPorts(ii).Signal;
            vectlens(ii)=max(hdlsignalvector(inp));
            if inp.Type.isMatrix
                foundMatrix=true;
            end
        end
        maxvect=max(vectlens);

        if~all(vectlens(vectlens~=0)==maxvect)
            error(message('hdlcoder:validate:unsupported',mfilename));
        end

        if foundMatrix
            if ninputs>2
                v(end+1)=hdlvalidatestruct(1,...
                message('hdlcoder:matrix:Only2InputAddSupported'));
            end
        end

        ins=[];
        for ii=1:ninputs
            ins=cat(1,ins,hC.PirInputPorts(ii).Signal);
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

    in1signal=hC.PirInputSignals(1);
    if(targetcodegen.targetCodeGenerationUtils.isAlteraMode()||targetcodegen.targetCodeGenerationUtils.isXilinxMode())&&in1signal.Type.isMatrix
        v=hdlvalidatestruct(1,...
        message('hdlcommon:targetcodegen:UnsupportedMatrixTypesTargetcodegen'));
    end
end



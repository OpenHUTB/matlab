function v=validateBlock(this,hC)



    v=hdlvalidatestruct;
    slbh=hC.SimulinkHandle;


    constMatrix=getBlockInfo(this,slbh);



    if isempty(constMatrix)

        dimsConstMatrix=-1;
    else
        dimsConstMatrix=length(size(constMatrix));
    end


    if(dimsConstMatrix~=2)&&(dimsConstMatrix~=3)
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:unsupportedConstMatrix'));
    end



    if~strcmpi(class(constMatrix),'single')&&~strcmpi(class(constMatrix),'double')
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:unsupportedConstMatrixType'));
    end



    if~targetcodegen.targetCodeGenerationUtils.isNFPMode()
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:unsupportedNfpScmTargetType'));
    end

    nfpOptions=this.getNFPImplParamInfo;
    if nfpOptions.Latency==int8(4)&&targetcodegen.targetCodeGenerationUtils.isNFPMode()
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
        ipSettings=fc.IPConfig.getIPSettings('Mul',dataType);

        if nfpOptions.CustomLatency>ipSettings.MaxLatency
            v(end+1)=hdlvalidatestruct(1,message('hdlcommon:nativefloatingpoint:InvalidCustomLatencySpecified',...
            hC.getBlockPath,num2str(ipSettings.MaxLatency)));
        end
    end
end
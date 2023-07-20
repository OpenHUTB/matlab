function v=validateBlock(this,hC)


    v=hdlvalidatestruct;



    [initC,dintegrity_on,ddtransfer_on,ip_samp_time,op_samp_time,...
    areRatesSynchronous,isAsyncRTAsWire]=this.getBlockInfo(hC);

    anyZero=any([ip_samp_time,op_samp_time]==0);
    anyInf=any([ip_samp_time,op_samp_time]==Inf);

    if anyZero||anyInf
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:validate:invalidrates'));
    end

    if ip_samp_time==op_samp_time

    elseif~dintegrity_on


        if~isAsyncRTAsWire...
            &&~(areRatesSynchronous&&ip_samp_time>=op_samp_time)


            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:validate:unsupportedrtmode'));
        end



        if isAsyncRTAsWire...
            &&~areRatesSynchronous
            v(end+1)=hdlvalidatestruct(2,...
            message('hdlcoder:validate:RTMismatchNumerics'));
        end
    elseif~ddtransfer_on


        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:validate:unsupportedrtmode'));
    end

    inSig=hC.PirInputSignals(1);
    leafType=inSig.Type.getLeafType;
    if leafType.isEnumType
        icClass=class(initC);
        if~isSLEnumType(icClass)
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:validate:InvalidRTInitialEnumValue'));
        end
        rtClass=leafType.Name;
        if~strcmp(icClass,rtClass)
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:validate:RTInitialEnumValueBadDT',...
            hC.Name,icClass,rtClass));
        end
    end
end



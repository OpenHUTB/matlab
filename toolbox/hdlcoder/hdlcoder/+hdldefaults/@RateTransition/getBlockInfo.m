function[initC,dintegrity_on,ddtransfer_on,inputRate,outputRate,...
    areRatesSynchronous,isAsyncRTAsWire]=getBlockInfo(this,hC)



    bfp=hC.SimulinkHandle;

    initC=hdlslResolve('X0',bfp);

    dintegrity_on=strcmpi(get_param(bfp,'Integrity'),'on');
    if dintegrity_on
        ddtransfer_on=strcmpi(get_param(bfp,'Deterministic'),'on');
    else

        ddtransfer_on=false;
    end

    in=hC.SLInputPorts(1).Signal;
    out=hC.SLOutputPorts(1).Signal;

    inputRate=hdlsignalrate(in);
    outputRate=hdlsignalrate(out);

    areRatesSynchronous=in.isRateSynchronous(out);

    isAsyncRTAsWire=strcmpi(getImplParams(this,'AsyncRTAsWire'),'on');
end


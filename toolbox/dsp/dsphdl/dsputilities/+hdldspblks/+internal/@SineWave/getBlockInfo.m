function blockInfo=getBlockInfo(this,hC)




    blockInfo=struct();


    hBlock=hC.SimulinkHandle;


    rto=get_param(hBlock,'RuntimeObject');


    for parmIdx=1:rto.NumRuntimePrms
        rto_names{parmIdx}=rto.RuntimePrm(parmIdx).Name;
    end


    samplePerPeriodIdx=find(strcmp('SpP_SineTable',rto_names));
    valuesSineTableIdx=find(strcmp('Values_SineTable',rto_names));
    sampPerPeriod=rto.RuntimePrm(samplePerPeriodIdx).Data;

    blockInfo.copies=length(sampPerPeriod);
    vstart=1;

    for sinTblIdx=1:blockInfo.copies
        vstop=vstart+sampPerPeriod(sinTblIdx)-1;
        blockInfo.valuesSineTable{sinTblIdx}=rto.RuntimePrm(valuesSineTableIdx).Data(vstart:vstop);
        vstart=vstop+1;

    end

    mwsvar=get_param(hBlock,'MaskWSVariables');
    qwave_wsvaridx=find(strncmpi('TableSize',{mwsvar.Name},length('TableSize')));
    blockInfo.qwave=(mwsvar(qwave_wsvaridx).Value==2);

    if(blockInfo.qwave)

        stateSinTblrtoidx=find(strcmp('State_SineTable',rto_names));
        blockInfo.tableState=rto.RuntimePrm(stateSinTblrtoidx).Data;
    end



    outputs=hC.SLOutputPorts;
    outsig=outputs.Signal;

    blockInfo.cplx=hdlsignaliscomplex(outsig);


    blockInfo.SimulinkRate=hC.PirOutputSignals(1).SimulinkRate;


    blockInfo.outWL=this.hdlslResolve('wordLen',hBlock);
    blockInfo.outFL=this.hdlslResolve('numFracBits',hBlock);

    blockInfo.blockName=hdllegalname(get_param(hBlock,'Name'));
end


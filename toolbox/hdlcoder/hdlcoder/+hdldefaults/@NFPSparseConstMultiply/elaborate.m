function hNewC=elaborate(this,hN,hC)




    hCInSignals=hC.SLInputSignals;
    hCOutSignals=hC.SLOutputSignals;


    slbh=hC.SimulinkHandle;


    [constMatrix,sharingFactor,useRAM]=getBlockInfo(this,slbh);


    earlyElaborate=true;
    nfpOptions=this.getNFPImplParamInfo;
    nfpCustomLatency=-1;
    fullPath=hC.Name;
    if ishandle(slbh)
        slObj=get_param(slbh,'Object');
        fullPath=[slObj.Path,'/',slObj.Name];
    end

    sschdlCustomLatency=hdlgetparameter('sschdlMatrixProductSumCustomLatency');
    if~isempty(sschdlCustomLatency)&&(sschdlCustomLatency>=0)
        nfpCustomLatency=sschdlCustomLatency;
        hdldisp(message('hdlcommon:nativefloatingpoint:sschdlSparseMatrixCustomLatency',...
        fullPath,num2str(sschdlCustomLatency)));
        nfpOptions.Latency=4;
        nfpOptions.CustomLatency=sschdlCustomLatency;
    end

    if nfpOptions.Latency==4
        nfpCustomLatency=nfpOptions.CustomLatency;
    end

    if(~earlyElaborate)

        [latency,fpDelays]=this.getscmLatency(hC,constMatrix,sharingFactor,nfpCustomLatency);
        if(latency==-1)
            error(message('hdlcoder:validate:unsupportedNfpScmTargetType'));
        end

        constMatrixSize=size(constMatrix);
        numelOfMatrix=prod(constMatrixSize);

        constMatrix=reshape(constMatrix,[1,numelOfMatrix]);


        hNewC=pirelab.getNFPSparseConstMultiplyComp(hN,hCInSignals,hCOutSignals,...
        constMatrixSize,constMatrix,latency,sharingFactor,fpDelays,nfpOptions,hC.Name);
    else

        multiplyAddMap=containers.Map('KeyType','char','ValueType','any');
        hNewC=transformnfp.elabNFPSparseConstMultiply(hN,hC,constMatrix,sharingFactor,...
        earlyElaborate,multiplyAddMap,nfpCustomLatency,useRAM);

        if this.drawBlockFromPIR

            hN.removeComponent(hC);
        end
    end

end
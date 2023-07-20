function demuxComp=getHardwareDemuxComp(hN,hInSignals,hOutSignals,compName)



    if nargin<4
        compName='hwdemux';
    end

    [vecLen,ht]=pirelab.getVectorTypeInfo(hInSignals(1));

    if vecLen>1
        demuxComp=getVectorHwDemuxComp(hN,hInSignals,hOutSignals,vecLen,ht,compName);
    else
        demuxComp=getScalarHwDemuxComp(hN,hInSignals,hOutSignals,compName);
    end

end

function demuxComp=getVectorHwDemuxComp(hN,hInSignals,hOutSignals,vecLen,hInType,compName)









    [fatDimLen,hOutType]=pirelab.getVectorTypeInfo(hOutSignals(1));

    dimLen=fatDimLen/vecLen;

    hCtrlInput=hInSignals(2);

    hHDInSignals=hdlhandles(vecLen,1);
    hHDOutSignals=hdlhandles(vecLen,1);
    hHDOutType=pirelab.getPirVectorType(hOutType,dimLen);
    for ii=1:vecLen
        hHDInSignals(ii)=hN.addSignal(hInType,sprintf('%s_in_%d',compName,ii));

        hHDOutSignals(ii)=hN.addSignal(hHDOutType,sprintf('%s_out_%d',compName,ii));
    end

    hHDScalarOut=hdlhandles(dimLen,vecLen);
    for ii=1:dimLen
        for jj=1:vecLen
            hHDScalarOut(ii,jj)=hN.addSignal(hOutType,sprintf('%s_out_%d_%d',compName,ii,jj));
        end
    end

    hdcomp=pirelab.getDemuxComp(hN,hInSignals(1),hHDInSignals);

    delayComps=hdlhandles(vecLen,1);
    for ii=1:vecLen
        delayComps(ii)=getScalarHwDemuxComp(hN,[hHDInSignals(ii),hCtrlInput],hHDOutSignals(ii),sprintf('%s_%d',compName,ii));
        hTmpMuxSignal=hdlhandles(dimLen,1);
        for jj=1:dimLen
            hTmpMuxSignal(jj)=hHDScalarOut(jj,ii);
        end
        hdcomp=pirelab.getDemuxComp(hN,hHDOutSignals(ii),hTmpMuxSignal);
    end



    hPreOut=hdlhandles(dimLen,1);
    hPreOutType=pirelab.getPirVectorType(hOutType,vecLen);
    for ii=1:dimLen
        hTmpMuxIn=hdlhandles(vecLen,1);
        for jj=1:vecLen
            hTmpMuxIn(jj)=hHDScalarOut(ii,jj);
        end

        hPreOut(ii)=hN.addSignal(hPreOutType,sprintf('%s_pre_out_%d',compName,ii));
        hdcomp=pirelab.getMuxComp(hN,hTmpMuxIn,hPreOut(ii));
    end

    demuxComp=pirelab.getMuxComp(hN,hPreOut,hOutSignals(1));%#ok<*NASGU>
end

function demuxComp=getScalarHwDemuxComp(hN,hInSignals,hOutSignals,compName)

    [dimLen,~]=pirelab.getVectorTypeInfo(hOutSignals(1));

    demuxComp=hN.addComponent2(...
    'kind','cgireml',...
    'Name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'EMLFileName','hdleml_hwdemux',...
    'EMLParams',{dimLen},...
    'EMLFlag_RunLoopUnrolling',false);

    if targetmapping.isValidDataType(hInSignals(1).Type)
        demuxComp.setSupportTargetCodGenWithoutMapping(true);
    end

end



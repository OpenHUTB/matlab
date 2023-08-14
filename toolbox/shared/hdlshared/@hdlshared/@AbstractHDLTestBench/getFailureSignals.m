function[hdlsignals,checkerFailure,errCnt]=getFailureSignals(this,snk)


    hdlsignals=[];
    errCnt=[];


    bdt=hdlgetparameter('base_data_type');

    [~,checkerFailure]=hdlnewsignal([snk.loggingPortName,'_testFailure'],'block',-1,0,0,bdt,'boolean');
    hdlregsignal(checkerFailure);
    hdlsignals=[hdlsignals,makehdlsignaldecl(checkerFailure)];

    outPorts=this.getHDLSignals('out',snk);
    for vec=1:length(outPorts)
        PortName=outPorts{vec};
        [~,errCntIdx]=hdlnewsignal([PortName,'_errCnt'],'block',-1,0,0,'integer','uint32');
        hdlregsignal(errCntIdx);
        hdlsignals=[hdlsignals,makehdlsignaldecl(errCntIdx)];%#ok
        errCnt=[errCnt,errCntIdx];%#ok
    end
end

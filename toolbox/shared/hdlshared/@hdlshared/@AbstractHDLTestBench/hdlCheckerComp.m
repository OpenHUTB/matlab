function[hdlbody,hdlsignals]=hdlCheckerComp(this,clkenb,snkDone,testFailure)




    bdt=hdlgetparameter('base_data_type');


    hdlsignals=[];
    hdlbody=[];

    if~isempty(this.OutportSnk)
        snkDoneSignals=[];
        tstFailureSignals=[];
        for instance=1:length(this.OutportSnk)
            snk=this.OutportSnk(instance);



            [failsignals,checkerFailure,errCnt]=this.getFailureSignals(snk);
            hdlsignals=[hdlsignals,failsignals];%#ok
            tstFailureSignals=[tstFailureSignals,checkerFailure];%#ok



            [ceOutbody,ceOutsignals,ce_out]=this.getCeOut(snk,clkenb);
            hdlbody=[hdlbody,ceOutbody];%#ok
            hdlsignals=[hdlsignals,ceOutsignals];%#ok


            hdlbody=[hdlbody,...
            this.insertComment({' Checker: Checking the data received from the DUT.'}),'\n'];%#ok



            [rdenbPort,addrPort,donePort,chkhdlbody,chkhdlsignals]=this.getCheckerPorts(snk);
            hdlsignals=[hdlsignals,chkhdlsignals];%#ok
            hdlbody=[hdlbody,chkhdlbody];%#ok



            hdlbody=[hdlbody,hdlsignalassignment(ce_out,rdenbPort)];%#ok



            [dlyChkBody,dlyChkSignals,check_enb]=this.hdlDelayChecking(instance,rdenbPort);
            hdlsignals=[hdlsignals,dlyChkSignals];%#ok
            hdlbody=[hdlbody,dlyChkBody];%#ok



            [refBody,refSignal]=this.hdlOutRefComp(instance,addrPort);
            hdlbody=[hdlbody,refBody];%#ok
            hdlsignals=[hdlsignals,refSignal];%#ok


            checkerBody=this.hdlchecker(rdenbPort,check_enb,addrPort,instance,errCnt,checkerFailure);
            hdlbody=[hdlbody,checkerBody];%#ok



            [~,checkDone]=hdlnewsignal(['check',num2str(instance),'_Done'],'block',-1,0,0,bdt,'boolean');
            hdlregsignal(checkDone);
            hdlsignals=[hdlsignals,makehdlsignaldecl(checkDone)];%#ok
            snkDoneSignals=[snkDoneSignals,checkDone];%#ok
            hdlbody=[hdlbody,this.hdltestdone(rdenbPort,donePort,checkDone,instance)];%#ok
        end
        hdlbody=[hdlbody,...
        this.insertComment({'Create done and test failure signal for output data'}),'\n'];
        hdlbody=[hdlbody,this.hdlandsignals(snkDone,snkDoneSignals)];
        hdlbody=[hdlbody,this.hdlorsignals(testFailure,tstFailureSignals)];
    end

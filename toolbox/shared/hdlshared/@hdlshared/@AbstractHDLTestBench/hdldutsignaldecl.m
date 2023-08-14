function hdlsignals=hdldutsignaldecl(this)


    inports=this.DUTInport;
    outports=this.DUTOutport;

    hdlsignals=[];

    isVhdl=hdlgetparameter('isvhdl');
    for m=1:length(inports)
        inport=inports(m);
        signame=inport.Name;
        sigvtype=inport.VType;
        sigsltype=inport.SLType;
        if isVhdl
            sigvector=inport.Vector;
        else
            sigvector=0;
        end
        [~,idx]=hdlnewsignal(signame,'block',-1,0,sigvector,sigvtype,sigsltype);
        hdlregsignal(idx);
        hdlsignals=[hdlsignals,makehdlsignaldecl(idx)];%#ok<*AGROW>
    end

    for m=1:length(outports)
        outport=outports(m);
        signame=outport.Name;
        sigvtype=outport.VType;
        sigsltype=outport.SLType;
        sigvector=outport.Vector;
        if hdlgetparameter('isvhdl')
            [~,idx]=hdlnewsignal(signame,'block',-1,0,sigvector,sigvtype,sigsltype);
        else
            [~,idx]=hdlnewsignal(signame,'block',-1,0,0,sigvtype,sigsltype);
        end
        hdlsignals=[hdlsignals,makehdlsignaldecl(idx)];
    end
    hdlsignals=[hdlsignals,'\n'];



    signalTable=hdlgetsignaltable;
    bdt=hdlgetparameter('base_data_type');
    for m=1:length(this.clockTable)
        signame=this.clockTable(m).Name;
        kind=this.clockTable(m).Kind;
        sigId=signalTable.findSignalFromName(signame);
        if isempty(sigId)
            [~,sigId]=hdlnewsignal(signame,'block',-1,0,0,bdt,'boolean');
            hdlregsignal(sigId);
            hdlsignals=[hdlsignals,makehdlsignaldecl(sigId)];
        end
        if kind==0
            signalTable.addClockSignal(sigId);
        elseif kind==1
            signalTable.addResetSignal(sigId);
        elseif kind==2
            signalTable.addClockEnableSignal(sigId);
        end
    end

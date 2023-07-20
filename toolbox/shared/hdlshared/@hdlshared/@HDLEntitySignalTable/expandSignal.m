function entitysignals=expandSignal(this,range,porthandles,...
    uname,block,complexity,dims,vtype,sltype,rate,forward)












    hdl_parameters=PersistentHDLPropSet;
    hdl_parameters=hdl_parameters.INI.struct;

    entitysignals=[];

    for i=1:length(porthandles)
        if porthandles(i)==-1
            porthandles(i)=[];
        end
    end

    count=1;
    for n=range
        if count>length(porthandles)
            ph=[];
        else
            ph=porthandles(count);
            count=count+1;
        end

        sigindex=[hdl_parameters.array_deref(1),num2str(n),hdl_parameters.array_deref(2)];




        if complexity


            name=[uname,sigindex];
            signal=hdlshared.HDLEntitySignal(name,'',ph,complexity,dims,vtype,sltype,rate,forward);
            idx1=this.addSignal(signal);


            pos=findstr(uname,hdl_parameters.complex_real_postfix);
            pos=pos(end);
            uname1=[uname(1:pos-1),hdl_parameters.complex_imag_postfix];
            name1=[uname1,sigindex];
            signal=hdlshared.HDLEntitySignal(name1,'',ph,0,dims,vtype,sltype,rate,forward);
            idx2=this.addSignal(signal);

            entitysignals=[entitysignals,idx1];

        else

            name=[uname,sigindex];
            signal=hdlshared.HDLEntitySignal(name,'',ph,complexity,dims,vtype,sltype,rate,forward);
            idx=this.addSignal(signal);

            entitysignals=[entitysignals,idx];

        end

    end

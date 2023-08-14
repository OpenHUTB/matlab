function entitysignals=hdlexpandvectorsignal(signal,range,porthandles)













    hN=pirNetworkForFilterComp;
    emitMode=isempty(hN);

    if~emitMode

        if~hdlsignalvector(signal)
            entitysignals=signal;
            return;
        end

        signalParts=signal.split;

        if nargin<2
            range=[];
        end
        if isempty(range)
            entitysignals=[signalParts.PirOutputSignals];
        else
            entitysignals=[];
            for ii=range
                entitysignals=[entitysignals,signalParts.PirOutputSignals(ii)];%#ok<AGROW>
            end
        end

    else
        uname=hdlsignalname(signal);
        isvector=hdlsignalvector(signal);
        complexity=hdlsignaliscomplex(signal);
        sltype=hdlsignalsltype(signal);
        rate=hdlsignalrate(signal);
        forward=hdlsignalforward(signal);

        if~hdlispirbased

            if hdlgetparameter('isvhdl')

                if hdlisinportsignal(signal)
                    portall=hdlgetallfromsltype(sltype,'inputport');
                    vtype=portall.portvtype;
                elseif hdlisoutportsignal(signal)
                    portall=hdlgetallfromsltype(sltype,'outputport');
                    vtype=portall.portvtype;
                else
                    vtype=hdlblockdatatype(sltype);
                end
            elseif hdlgetparameter('isverilog')

                vtype=hdlsignalvtype(signal);
            end

        end

        if isvector==0
            if hdlgetparameter('debug')>2
                warning(message('HDLShared:directemit:nonvectorinput',uname));
            end
            entitysignals=signal;
            return;
        end

        if length(isvector)==1||isvector(2)==0||isvector(1)==1||isvector(2)==1

            if nargin<3
                porthandles=-1;
            end
            if nargin<2
                range=0:max(isvector)-1;
            end

            if hdlispirbased


                entitysignals=localExpandPirSignal(signal,range,porthandles);

            else

                signalTable=hdlgetsignaltable;



                entitysignals=signalTable.expandSignal(range,porthandles,...
                uname,'',complexity,0,vtype,sltype,rate,forward);
            end

        else
            error(message('HDLShared:directemit:matrixunsupported'));
        end
    end


    function entitysignals=localExpandPirSignal(signal,range,porthandles)
        entitysignals=[];
        network=signal.Owner;
        array_deref=hdlgetparameter('array_deref');
        uname=hdlsignalname(signal);
        sltype=hdlsignalsltype(signal);
        vtype=hdlblockdatatype(sltype);
        complexity=hdlsignaliscomplex(signal);
        rate=hdlsignalrate(signal);
        dims=0;
        forward=hdlsignalforward(signal);

        count=1;
        for n=range
            if count>length(porthandles)
                ph=-1;
            else
                ph=porthandles(count);
                count=count+1;
            end

            sigindex=[array_deref(1),num2str(n),array_deref(2)];




            fakesignal=true;




            imag_signal_avl=complexity&&~isempty(hdlsignalimag(signal));

            if imag_signal_avl





                name{1}=[uname,sigindex];
                name{2}=[hdlsignalname(hdlsignalimag(signal)),sigindex];

            else




                name=[uname,sigindex];
            end

            newsignal=pirhdlnewsignal(network,name,ph,imag_signal_avl,...
            dims,vtype,sltype,rate,forward,fakesignal);


            entitysignals=[entitysignals,newsignal];%#ok

        end


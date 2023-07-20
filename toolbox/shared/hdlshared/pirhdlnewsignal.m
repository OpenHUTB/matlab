function hS=pirhdlnewsignal(hN,name,port,isComplex,...
    dims,vType,slType,rate,forward,fake)

























    hNp=pirNetworkForFilterComp;
    emitMode=isempty(hNp);

    if nargin<8
        rate=0;
    end

    if nargin<9
        forward=0;
    end

    if emitMode
        if nargin<10
            fake=0;
        end






        if isempty(isComplex)
            isComplex=false;
        end



        if(isComplex&&fake)
            if~(iscell(name)&&numel(name)==2)
                error(message('HDLShared:directemit:nameforimagmissing'));
            else
                name_real=name{1};
                name_imag=name{2};
            end
        elseif(isComplex==1)

            name_real=[name,hdlgetparameter('complex_real_postfix')];
            name_imag=[name,hdlgetparameter('complex_imag_postfix')];
        else
            name_real=name;
        end

        if length(dims)>1&&all(dims==[0,0])

            dims=0;
        end

        hT=getpirsignaltype(slType,0,dims);


        if fake

            hS=hN.addFakeSignal(hT,name_real);
        else


            hS=hN.addSignal(hT,name_real);
        end

        hS.SimulinkHandle=port;
        hS.SimulinkRate=rate;
        hS.VType(vType);

        if forward==0
            hS.Forward([]);
        else
            hS.Forward(forward);
        end

        if(isComplex)

            if fake




                hS2=hN.addFakeSignal(hT,name_imag);
            else


                hS2=hN.addSignal(hT,name_imag);
            end

            hS2.SimulinkHandle=port;
            hS2.SimulinkRate=rate;
            hS2.VType(vType);

            if forward==0
                hS2.Forward([]);
            else
                hS2.Forward(forward);
            end

            hS2.Imag([]);
            hS.Imag(hS2);

        else

            hS.Imag([]);
        end
    else

        if length(dims)>1&&all(dims==[0,0])

            dims=0;
        end

        hT=getpirsignaltype(slType,isComplex,dims);

        hS=hN.addSignal(hT,name);

        hS.SimulinkHandle=port;
        hS.SimulinkRate=rate;
        hS.VType(vType);

        if forward==0
            hS.Forward([]);
        else
            hS.Forward(forward);
        end

    end


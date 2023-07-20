function prm=buildBlockParams(this,hC)
















    bfp=hC.SimulinkHandle;

    switch(this.Blocks{1})
    case 'commdigbbndpm3/BPSK Modulator Baseband'
        prm.type='bpsk';
        prm.M=2;
        enc='Binary';
        prm.IntegerInput=false;
    case 'commdigbbndpm3/QPSK Modulator Baseband'
        prm.type='qpsk';
        prm.M=4;
        enc=get_param(bfp,'Enc');
        prm.IntegerInput=strcmpi(get_param(bfp,'InType'),'Integer');
    case 'commdigbbndpm3/M-PSK Modulator Baseband'
        prm.type='mpsk';
        prm.M=this.hdlslResolve('M',bfp);
        mapping=this.hdlslResolve('Mapping',bfp);
        enc=get_param(bfp,'Enc');
        prm.IntegerInput=strcmpi(get_param(bfp,'InType'),'Integer');
    end


    size=hdlsignalsizes(hC.PirOutputSignals);
    prm.outWL=size(1);
    prm.outFL=size(2);
    prm.phaseOffset=this.hdlslResolve('Ph',bfp);





    if~size(1)==0
        rto=get_param(bfp,'RunTimeObject');









        if strcmpi(enc,'Gray')
            constel=pskmod(0:(prm.M-1),prm.M,prm.phaseOffset,enc);
        else
            if strcmpi(enc,'User-defined')
                [~,symmapping]=sort(mapping);
                symmapping=symmapping-1;
            else
                symmapping=0:(prm.M-1);
            end
            constel=exp(1i*(2*pi*symmapping/prm.M+prm.phaseOffset));
        end
        constel_fi=fi(constel,1,prm.outWL,prm.outFL);

        prm.LUTvalues=constel_fi;
    else
        prm.LUTvalues=0;
    end


end



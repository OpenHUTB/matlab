function bw=getBandwidth(FR,SCS,NRB)

    if strcmp(FR,'FR1')
        bws=[5,10,15,20,25,30,40,50,60,70,80,90,100];
    else
        bws=[50,100,200,400];
    end
    fh=str2func(['nr5g.internal.wavegen.get',FR,'BandwidthTable']);
    table=fh();


    bw=bws(table{[num2str(SCS),'kHz'],:}==NRB);
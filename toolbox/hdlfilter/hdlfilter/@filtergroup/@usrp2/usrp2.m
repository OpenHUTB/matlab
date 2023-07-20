function this=usrp2




    this=filtergroup.usrp2;



    D=1;
    Fpass=0.01;
    Astop=60;

    h=fdesign.decimator(128,'CIC',D,'Fp,Ast',Fpass,Astop);
    Hcicd=design(h,'multisection');

    set(Hcicd,'Arithmetic','fixed',...
    'InputWordLength',24,...
    'InputFracLength',0,...
    'FilterInternals','Fullprecision',...
    'NumberofSections',4);
    Hcicd.specifyall;
    Hcicd.OutputWordLength=Hcicd.InputWordLength;
    Hcicd.OutputFracLength=Hcicd.InputFracLength;


    N=6;
    TW=0.1;
    h=fdesign.decimator(2,'Halfband','n,tw',N,TW);

    Hshbd=design(h,'equiripple',...
    'StopbandShape','flat');
    set(Hshbd,'Arithmetic','fixed',...
    'InputWordLength',18,...
    'InputFracLength',0,...
    'CoeffWordLength',18,...
    'CoeffAutoScale',true,...
    'FilterInternals','Fullprecision');


    c=Hshbd.Numerator*2^Hshbd.NumFracLength;
    Hshbd.Numerator=c;


    Hshbd.specifyall;
    Hshbd.OutputWordLength=Hshbd.InputWordLength;
    Hshbd.OutputFracLength=Hshbd.InputFracLength;


    h=fdesign.decimator(2,'Halfband','n',N);
    Hbhbd=design(h,'window');

    set(Hbhbd,'Arithmetic','fixed',...
    'InputWordLength',18,...
    'InputFracLength',0,...
    'CoeffWordLength',18,...
    'CoeffAutoScale',true,...
    'FilterInternals','Fullprecision');

    c=Hbhbd.Numerator*2^Hbhbd.NumFracLength;
    Hbhbd.Numerator=c;

    Hbhbd.specifyall;
    Hbhbd.OutputWordLength=16;
    Hbhbd.OutputFracLength=Hbhbd.InputFracLength;


    this.Rxchain=cascade(Hcicd,Hshbd,Hbhbd);



    h=fdesign.interpolator(2,'Halfband','n',N);
    Hbhbi=design(h,'window',AllowLegacyFilters=true);

    set(Hbhbi,'Arithmetic','fixed',...
    'InputWordLength',18,...
    'InputFracLength',0,...
    'CoeffWordLength',18,...
    'CoeffAutoScale',true,...
    'FilterInternals','Fullprecision');

    c=Hbhbi.Numerator*2^Hbhbi.NumFracLength;
    Hbhbi.Numerator=c;

    Hbhbi.specifyall;
    Hbhbi.OutputWordLength=Hbhbi.InputWordLength;
    Hbhbi.OutputFracLength=Hbhbi.InputFracLength;


    N=6;
    TW=0.1;
    h=fdesign.interpolator(2,'Halfband','n,tw',N,TW);

    Hshbi=design(h,'equiripple',...
    'StopbandShape','flat',AllowLegacyFilters=true);

    set(Hshbi,'Arithmetic','fixed',...
    'InputWordLength',18,...
    'InputFracLength',0,...
    'CoeffWordLength',18,...
    'CoeffAutoScale',true,...
    'FilterInternals','Fullprecision');


    c=Hshbi.Numerator*2^Hshbi.NumFracLength;
    Hshbi.Numerator=c;


    Hshbi.specifyall;
    Hshbi.OutputWordLength=Hshbi.InputWordLength;
    Hshbi.OutputFracLength=Hshbi.InputFracLength;


    D=1;
    Fpass=0.01;
    Astop=60;

    h=fdesign.interpolator(128,'CIC',D,'Fp,Ast',Fpass,Astop);
    Hcici=design(h,'multisection',AllowLegacyFilters=true);

    set(Hcici,'Arithmetic','fixed',...
    'InputWordLength',18,...
    'InputFracLength',0,...
    'FilterInternals','Fullprecision',...
    'NumberofSections',4);
    Hcici.specifyall;
    Hcici.OutputWordLength=Hcici.InputWordLength;
    Hcici.OutputFracLength=Hcici.InputFracLength;

    this.TxChain=cascade(Hbhbi,Hshbi,Hcici);

    this.FilterStructure='USRP2';




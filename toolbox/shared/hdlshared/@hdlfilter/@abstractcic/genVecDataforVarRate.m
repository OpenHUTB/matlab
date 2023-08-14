function[indata,outdata]=genVecDataforVarRate(this,filterobj,inputdata,arithisdouble)










    numinputvectors=length(inputdata);

    inputvector=[inputdata,0,inputdata];

    loadenbdata=[1,zeros(1,(numinputvectors-1))];



    rate1=resolveTBRateStimulus(this);

    ratedata=ones(1,numinputvectors+4)*rate1;


    maxrate=this.phases;
    ratesize=max(2,ceil(log2(maxrate+1)));


    if~arithisdouble
        inputvector=fi(inputvector,true,filterobj.InputWordLength,filterobj.InputFracLength,...
        'fimath',fimath('RoundMode','round','OverflowMode','saturate'));

        loadenbdata=fi(loadenbdata,false,1,0,...
        'fimath',fimath('RoundMode','round','OverflowMode','saturate'));

        ratedata=fi(ratedata,false,ratesize,0,...
        'fimath',fimath('RoundMode','round','OverflowMode','saturate'));
    end

    indata={inputvector,loadenbdata,ratedata};



    inputdata1=inputdata;

    if~arithisdouble
        indata1=fi(inputdata1,true,filterobj.InputWordLength,filterobj.InputFracLength,...
        'fimath',fimath('RoundMode','round','OverflowMode','saturate'));
    else
        indata1=inputdata1;
    end

    filterobj.persistentmemory=false;




    owl=filterobj.OutputWordLength;
    ofl=filterobj.OutputFracLength;


    rates=1:this.phases;
    bitgain=ceil(this.NumberOfSections*log2(rates));
    bg=bitgain(find(rates==rate1));


    filterobj.OutputWordLength=filterobj.SectionWordLengths(end);
    filterobj.OutputFracLength=filterobj.SectionFracLengths(end);


    rcf=filterobj.getratechangefactors;
    if rcf(1,1)==1
        filterobj.DecimationFactor=rate1;
    else
        filterobj.InterpolationFactor=rate1;
    end
    outdata1=filter(filterobj,indata1);
    ofi1=fi(zeros(1,length(outdata1)),1,owl,ofl-bg,'RoundMode','floor','OverflowMode','wrap');
    ofi1(:)=outdata1(:);

    outdata=ofi1;




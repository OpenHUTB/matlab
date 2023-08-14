function[indata,outdata]=genVecDataforVarRate(this,filterobj,inputdata,arithisdouble)










    numinputvectors=length(inputdata);

    inputvector=[inputdata,0,inputdata];

    loadenbdata=[1,zeros(1,(numinputvectors-1))];


    cicstage=[];

    for n=1:length(filterobj.Stage)
        if isa(filterobj.Stage(n),'mfilt.abstractcic')
            cicstage=[cicstage,n];%#ok
        end
    end
    if numel(cicstage)>1
        error(message('HDLShared:hdlfilter:unsupportedcascade'));
    end


    rate1=resolveTBRateStimulus(this.Stage(cicstage));

    ratedata=ones(1,numinputvectors+4)*rate1;


    maxrate=this.Stage(cicstage).phases;
    ratesize=max(2,ceil(log2(maxrate+1)));


    if~arithisdouble
        inputvector=fi(inputvector,true,filterobj.Stage(1).InputWordLength,filterobj.Stage(1).InputFracLength,...
        'fimath',fimath('RoundMode','round','OverflowMode','saturate'));

        loadenbdata=fi(loadenbdata,false,1,0,...
        'fimath',fimath('RoundMode','round','OverflowMode','saturate'));

        ratedata=fi(ratedata,false,ratesize,0,...
        'fimath',fimath('RoundMode','round','OverflowMode','saturate'));
    end

    indata={inputvector,loadenbdata,ratedata};



    inputdata1=inputdata;

    if~arithisdouble
        indata1=fi(inputdata1,true,filterobj.Stage(1).InputWordLength,filterobj.Stage(1).InputFracLength,...
        'fimath',fimath('RoundMode','round','OverflowMode','saturate'));
    else
        indata1=inputdata1;
    end

    filterobj.persistentmemory=false;





    cicfiltobj=filterobj.Stage(cicstage);

    if isa(cicfiltobj,'mfilt.cicdecim')
        cicfiltobj.DecimationFactor=rate1;
    else
        cicfiltobj.InterpolationFactor=rate1;
    end
    owl=cicfiltobj.OutputWordLength;
    ofl=cicfiltobj.OutputFracLength;

    rates=1:this.stage(cicstage).phases;
    bitgain=ceil(cicfiltobj.NumberOfSections*log2(rates));
    bg=bitgain(find(rates==rate1));


    cicfiltobj.OutputWordLength=cicfiltobj.SectionWordLengths(end);
    cicfiltobj.OutputFracLength=cicfiltobj.SectionFracLengths(end);

    for n=1:length(filterobj.Stage)
        if n==cicstage
            y=filter(cicfiltobj,indata1);





            outdata1=fi(zeros(1,length(y)),1,owl,ofl-bg,'RoundMode','floor','OverflowMode','wrap');
            outdata1(:)=y(:);




            if n<length(filterobj.Stage)
                inputnext=fi(zeros(1,length(outdata1)),1,...
                filterobj.stage(n+1).InputWordLength,filterobj.Stage(n+1).InputFracLength);
                inputnext.int=outdata1.int;
                indata1=inputnext;
            end
        else
            outdata1=filter(filterobj.Stage(n),indata1);
            indata1=outdata1;
        end
    end













    outdata=outdata1;




function counterComp=getCounterComp(hN,hInSignals,hOutSignals,...
    type,initval,stepval,maxval,resetport,loadport,enbport,dirport,...
    compName,countFrom)














    if(nargin<13)
        countFrom=initval;
    end

    if(nargin<12)
        compName='counter';
    end


    wordlen=hOutSignals(1).Type.WordLength;
    fraclen=-hOutSignals(1).Type.FractionLength;
    issigned=hOutSignals(1).Type.Signed;
    freerun=strcmpi(type,'Free running');
    checkCounterParams(wordlen,fraclen,issigned,initval,countFrom,stepval,maxval,freerun);

    counterComp=pircore.getCounterComp(hN,hInSignals,hOutSignals,...
    type,initval,stepval,maxval,resetport,loadport,enbport,dirport,compName,countFrom);
end

function countrange=checkCounterParams(wordlen,fraclen,issigned,initval,minval,stepval,maxval,freerun)











    if~isequal(wordlen,floor(wordlen))||wordlen<=0
        error(message('hdlsllib:hdlsllib:wordlength'));
    elseif issigned&&wordlen==1
        error(message('hdlsllib:hdlsllib:signedwordlength'));
    end
    maxwlen=125;
    if wordlen>maxwlen
        error(message('hdlsllib:hdlsllib:maxwordlength',sprintf('%d',maxwlen)));
    end
    wordlen=double(wordlen);


    if~isequal(fraclen,floor(fraclen))||fraclen<0
        error(message('hdlsllib:hdlsllib:fraclength'));
    end


    if~issigned&&(fraclen>wordlen)
        error(message('hdlsllib:hdlsllib:fraclengthunsigned'));
    elseif issigned&&(fraclen>=wordlen)
        error(message('hdlsllib:hdlsllib:fraclengthsigned'));
    end


    countrange=[0,2^wordlen-1]-issigned*(2^(wordlen-1));


    CheckCountValue(countrange,fraclen,initval,'Initial value');

    if~freerun

        CheckCountValue(countrange,fraclen,minval,'Count from value');

        CheckCountValue(countrange,fraclen,maxval,'Count to value');


        sortedval=sort([minval,maxval]);
        if((initval<sortedval(1))||(initval>sortedval(2)))
            error(message('hdlsllib:hdlsllib:initoutofrange',initval,minval,maxval));
        end
    end


    if stepval==0
        error(message('hdlsllib:hdlsllib:zerostepvalue'));
    else


        CheckCountValue(countrange,fraclen,abs(stepval),'Step value');
    end
end


function CheckCountValue(countrange,fraclen,userval,valname)

    countval=userval*(2^fraclen);

    if(countval<countrange(1))||(countval>countrange(2))
        error(message('hdlsllib:hdlsllib:countvalrange',valname));
    end

    if~isequal(countval,floor(countval))
        error(message('hdlsllib:hdlsllib:countfracrange',valname));
    end
end




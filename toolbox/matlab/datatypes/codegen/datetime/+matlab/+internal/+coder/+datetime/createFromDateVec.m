%#codegen
function t=createFromDateVec(inData,tz)










    coder.allowpcode('plain');

    nfields=numel(inData);

    coder.internal.assert(iscell(inData),'MATLAB:datetime:mexErrors:InvalidInput');
    coder.internal.errorIf((nfields~=3)&&(nfields~=6)&&(nfields~=7),'MATLAB:datetime:InvalidNumericData');


    firstField=inData{1};
    numDims=ndims(firstField);
    numElem=numel(firstField);
    sz=size(firstField);


    coder.unroll()
    for i=1:nfields
        currentField=inData{i};
        coder.internal.assert(isnumeric(currentField)&&~issparse(currentField),'MATLAB:datetime:mexErrors:InvalidInput');
        coder.internal.assert(~any(imag(currentField),'all'),'MATLAB:datetime:InputMustBeReal');
        coder.internal.assert(ndims(currentField)==numDims,'MATLAB:datetime:InputSizeMismatch');
        coder.internal.assert(isequal(size(currentField),sz),'MATLAB:datetime:InputSizeMismatch');
    end

    t=createFromDateVecUTC(nfields,inData,numElem);
end

function t=createFromDateVecUTC(nfields,fieldValues,nelem)
    MSPerSecond=1000;
    MSPerMinute=60000;
    MSPerDay=86400000;

    haveMillis=(nfields==7);
    t=complex(zeros(size(fieldValues{1})));
    coder.unroll(coder.internal.isConst(nelem))
    for i=1:nelem
        year=fieldValues{1}(i);
        month=fieldValues{2}(i);
        day=fieldValues{3}(i);

        hour=0;
        minute=0;
        second=0;
        fracSecs=0;

        if nfields>=6
            hour=fieldValues{4}(i);
            minute=fieldValues{5}(i);
            second=fieldValues{6}(i);
            if(haveMillis)
                fracSecs=fieldValues{7}(i);
            end
        end

        check=year+month+day+hour+minute+second+fracSecs;

        if isfinite(check)


            allIntegers=(ceil(year)==year&&ceil(month)==month&&ceil(day)==day&&...
            ceil(hour)==hour&&ceil(minute)==minute);

            coder.internal.errorIf(~allIntegers&&haveMillis,'MATLAB:datetime:MustBeIntegerSecond');
            coder.internal.errorIf(~allIntegers&&~haveMillis,'MATLAB:datetime:MustBeInteger');
            coder.internal.errorIf(haveMillis&&ceil(second)~=second,'MATLAB:datetime:MustBeIntegerSecond');

            wholeDays=ymd2days(year,month,day);
            t(i)=complex(wholeDays);
            t(i)=matlab.internal.coder.doubledouble.times(t(i),MSPerDay);
            t(i)=matlab.internal.coder.doubledouble.plus(t(i),(60*hour+minute)*MSPerMinute);


            if(haveMillis)
                if((fracSecs<0)||(MSPerSecond<=fracSecs))
                    wholeSecsFromMillis=floor(fracSecs/MSPerSecond);
                    second=second+wholeSecsFromMillis;
                    fracSecs=fracSecs-wholeSecsFromMillis*MSPerSecond;
                end
            else
                fracSecs=second*MSPerSecond;
                second=floor(second);
                fracSecs=fracSecs-second*MSPerSecond;
            end
            t(i)=matlab.internal.coder.doubledouble.plus(t(i),second*MSPerSecond);
            t(i)=matlab.internal.coder.doubledouble.plus(t(i),fracSecs);
        else
            t(i)=check;
        end


    end

end


function dn=ymd2days(y,mo,d)



    if(mo<1||mo>12)
        [k,mo]=divmod(mo-1,12);
        y=y+k;
        mo=mo+1;
    end

    if(mo<3)
        y=y-1;
        mo=mo+9;
    else
        mo=mo-3;
    end
    dn=365*y+floor(y/4)-floor(y/100)+floor(y/400)+floor((153*mo+2)/5)+d+60;
    dn=dn-719529;

end

function[n,rem]=divmod(a,b)
    assert(b>0);
    n=floor(a/b);
    rem=a-n*b;
end
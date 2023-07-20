function fvect=computeFrequencyInputFrequencyVector(obj,dims)







    if any(dims==0)
        return
    end


    range='whole';
    nFFT=dims(1);
    if~obj.pTwoSidedSpectrum
        range='half';
        if~getPropertyValue(obj,'VectorScopeLegacyMode')
            if(mod(dims(1),2)==0)


                nFFT=dims(1)*2-1;
            else
                nFFT=(dims(1)-1)*2;
            end
        end
    end


    fvect=psdfreqvec(nFFT,obj.pSampleRate,range,obj.pTwoSidedSpectrum);
end

function w=psdfreqvec(Npts,Fs,Range,CenterDC)



    if isempty(Fs)
        Fs=2*pi;
    end
    freq_res=Fs/Npts;
    w=freq_res*(0:Npts-1);



    Nyq=Fs/2;
    half_res=freq_res/2;


    [isNPTSodd,halfNPTS,ishalfNPTSodd,quarterNPTS]=NPTSinfo(Npts);

    if isNPTSodd

        w(halfNPTS)=Nyq-half_res;
        w(halfNPTS+1)=Nyq+half_res;
    else

        w(halfNPTS)=Nyq;
    end
    w(Npts)=Fs-freq_res;


    w=finalgrid(w,Npts,Nyq,Range,CenterDC,isNPTSodd,ishalfNPTSodd,halfNPTS,quarterNPTS);
end


function[isNPTSodd,halfNPTS,ishalfNPTSodd,quarterNPTS]=NPTSinfo(NPTS)




    isNPTSodd=false;
    if rem(NPTS,2)
        isNPTSodd=true;
    end


    if isNPTSodd
        halfNPTS=(NPTS+1)/2;
    else
        halfNPTS=(NPTS/2)+1;
    end


    ishalfNPTSodd=false;
    if rem(halfNPTS,2)
        ishalfNPTSodd=true;
    end


    if ishalfNPTSodd
        quarterNPTS=(halfNPTS+1)/2;
    else
        quarterNPTS=(halfNPTS/2)+1;
    end
end


function w=finalgrid(w,Npts,Nyq,Range,CenterDC,isNPTSodd,ishalfNPTSodd,halfNPTS,quarterNPTS)



    switch lower(Range)
    case 'whole'


        if CenterDC
            if isNPTSodd
                negEndPt=halfNPTS;
            else
                negEndPt=halfNPTS-1;
            end
            w=[-fliplr(w(2:negEndPt)),w(1:halfNPTS)];
        end

    case 'half'
        w=w(1:halfNPTS);



        if CenterDC
            if ishalfNPTSodd
                negEndPt=quarterNPTS;
            else
                quarterNPTS=quarterNPTS-1;
                negEndPt=quarterNPTS;
            end
            w=[-fliplr(w(2:negEndPt)),w(1:quarterNPTS)];
            if~rem(Npts,4)


                w(end)=Nyq/2;
            end
        end
    end
    w=w(:);
end


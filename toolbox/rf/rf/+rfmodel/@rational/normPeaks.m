function[maxFreq,maxValue,peakFreqs,peakValues,freqs,ns,maxPoleFreq]=normPeaks(fit)




    nPorts=size(fit,1);
    D=real(reshape([fit.D],nPorts,nPorts));
    normAtInfinity=norm(D);

    allPoles=unique(vertcat(fit(:).A));
    if isempty(allPoles)
        maxFreq=Inf;
        maxValue=normAtInfinity;
        peakFreqs=Inf;
        peakValues=normAtInfinity;
        freqs=[0;1e9];
        ns=[normAtInfinity;normAtInfinity];
        maxPoleFreq=[];
        return
    end

    poleFreqsI=imag(allPoles(imag(allPoles)>0))/(2*pi);
    poleFreqsR=abs(real(allPoles(imag(allPoles)==0)))/(2*pi);
    poleFreqs=unique([poleFreqsI;poleFreqsR]);
    maxPoleFreq=poleFreqs(end);
    freqsOfInterest=unique([0;poleFreqs;2*maxPoleFreq]);


    n=20;
    alpha=(1:n)'/n;
    freqsBelow=(1-alpha)*freqsOfInterest(1:end-1)'+alpha*freqsOfInterest(2:end)';
    freqsBelow=unique([freqsOfInterest(1);freqsBelow(:)]);

    freqsAbove=1./(1./freqsBelow(end)*alpha);
    freqs=unique([freqsBelow;freqsAbove(:)]);

    ns=normresp(fit,freqs);
    assert(length(ns)>=3)


    idx=1+find(ns(1:end-2)<ns(2:end-1)&ns(2:end-1)>ns(3:end));
    if ns(1)>ns(2)
        idx=[2;idx];
    end
    if ns(end-1)<ns(end)&&ns(end)>normAtInfinity
        idx=[idx;length(ns)-1];
    end
    if isempty(idx)
        maxFreq=freqs(1);
        maxValue=ns(1);
        peakFreqs=freqs(1);
        peakValues=ns(1);
        return
    end

    fitaux=createFitAux(fit);
    if isempty(fitaux)
        f=@(x)goldenfun(x,fit);
    else
        f=@(x)goldenfunwithaux(x,fitaux);
    end


    peakFreqs=zeros(size(idx));
    peakValues=zeros(size(idx));
    for k=1:length(idx)
        ax=freqs(idx(k)-1);
        bx=freqs(idx(k));
        cx=freqs(idx(k)+1);
        [peakFreqs(k),fx]=rfmodel.rational.rfmin(ax,bx,cx,f,1e-12);
        peakValues(k)=-fx;
    end

    [maxValue,idx]=max(peakValues);
    maxFreq=peakFreqs(idx);
    if maxValue<normAtInfinity
        maxFreq=Inf;
        maxValue=normAtInfinity;
        peakFreqs=[peakFreqs;Inf];
        peakValues=[peakValues;normAtInfinity];
    end


end

function ns=normresp(fit,freqs)
    data=freqresp(fit,freqs);
    if ndims(data)==3
        for i=length(freqs):-1:1
            ns(i,1)=norm(data(:,:,i));
        end
    else
        ns=abs(data);
    end
end

function fx=goldenfun(freq,fit)

    resp=freqresp(fit,freq);
    fx=-norm(resp);
end

function fx=goldenfunwithaux(freq,fitaux)

    resp=freqrespaux(fitaux,freq);
    fx=-norm(resp);
end

function fitaux=createFitAux(fit)

    if all(length(fit(1).A)==cellfun(@length,{fit(:).A}))&&...
        all(fit(1).A==[fit(:).A],"all")
        fitaux.a=[fit(1).A];
        fitaux.ct=[fit(:).C].';
        fitaux.dt=[fit(:).D].';
        fitaux.m=size(fit,1);
        fitaux.n=size(fit,2);
    else
        fitaux=[];
    end
end

function[resp,freq]=freqrespaux(fitaux,freq)
    s=2j*pi*freq;
    if isempty(fitaux.a)
        x=fitaux.dt;
    else
        y=1./(s-fitaux.a);
        x=fitaux.dt+fitaux.ct*y;
    end
    resp=reshape(x,fitaux.m,fitaux.n);
end

function varargout=passivitycore(fit,xlimits)

































    [maxFreq,maxValue,peakFreqs,peakValues,freqs,ns,maxPoleFreq]=normPeaks(fit);

    [freqs,idx]=unique([freqs;peakFreqs]);
    temp=[ns;peakValues];
    ns=temp(idx);

    if isinf(maxFreq)
        fmax=2*maxPoleFreq;
    else
        fmax=2*max(maxFreq,maxPoleFreq);
    end
    xp=floor(log10(fmax));
    fmax=ceil(fmax/10^xp)*10^xp;

    if nargin<2||isempty(xlimits)
        xlimits=[0,fmax];
    elseif isscalar(xlimits)
        validateattributes(xlimits,{'double'},{'scalar','positive'})
        xlimits=[0,xlimits];
    else
        validateattributes(xlimits,{'double'},...
        {'vector','numel',2,'nonnegative','increasing'})
    end

    [~,e,u]=engunits(fmax);
    if maxValue<1
        plot(e*freqs,ns)
        axis([e*xlimits(1),e*xlimits(2),-inf,1])
        title(sprintf('Fit passive, H_\\infty norm is %s at %s.',...
        formatHInftyNorm(maxValue),formatFreq(maxFreq)))
    else
        plot(e*freqs,ns,...
        e*maxFreq,maxValue,'ro',...
        [0,e*freqs(end)],[1,1],'k--',...
        [0,e*freqs(end)],[maxValue,maxValue],'r--')
        xlim(e*xlimits)
        title(sprintf('Fit not passive, H_\\infty norm is %s at %s.',...
        formatHInftyNorm(maxValue),formatFreq(maxFreq)))
    end
    xlabel(sprintf('Frequency (%sHz)',u))
    ylabel('norm(H)')

    if nargout>0
        varargout{1}=maxFreq;
        varargout{2}=maxValue;
        varargout{3}=freqs;
        varargout{4}=ns;
    end
end

function str=formatFreq(f)
    if isinf(f)
        str=sprintf('%-s','Inf Hz');
    else
        [freq,~,u]=engunits(f);
        str=sprintf('%g %sHz',freq,u);
    end
end

function str=formatHInftyNorm(x)
    if x>=2
        str=sprintf('%g',x);
    elseif x==1
        str='1';
    elseif x<1
        str=sprintf('1 - %.3e',1-x);
    else
        str=sprintf('1 + %.3e',x-1);
    end
end

function plotdata(data,freq,ElemNumber)

    hfig=gcf;
    if nargin<3
        if~isreal(data)
            titlestr=sprintf('Impedance');
        else
            titlestr=sprintf('Return Loss');
        end
    else
        str1=sprintf('element %d',ElemNumber);
        if~isreal(data)
            titlestr=sprintf('Active impedance (%s)',str1);
        else
            titlestr=sprintf('Active return loss (%s)',str1);
        end
    end

    if~isempty(get(groot,'CurrentFigure'))
        clf(hfig);
    end
    freq=unique(freq,'stable');
    [freqval,~,U]=engunits(freq);

    if isreal(data)
        if numel(freq)==1
            plot(freqval,data,'bo');
        else
            plot(freqval,data,'b','LineWidth',2);
        end
        ylabel('Magnitude (dB)');
        title(titlestr);
    else
        if numel(freq)==1
            plot(freqval,real(data),'bo',freqval,imag(data),'ro');
        else
            plot(freqval,real(data),'b',freqval,imag(data),'r','LineWidth',2);
        end
        title(titlestr);
        ylabel('Impedance (ohms)');
        legend('Resistance','Reactance','Location','Best');
    end
    grid on;
    xlabel(['Frequency (',U,'Hz)']);


    if antennashared.internal.figureForwardState(hfig)
        shg;
    end

end
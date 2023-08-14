function plotdatareal(freq,data,U,val,legstr,haxes,numelems,isvswr)

    cla(haxes);
    hlines=plot(haxes,freq.',data(:,val));
    hfig=haxes.Parent;
    cv=em.internal.colorvector(numelems);
    if isscalar(freq)
        for m=1:length(hlines)
            hlines(m).Marker='o';
            hlines(m).Color=cv(m,:);
        end
    else
        for m=1:length(hlines)
            hlines(m).LineStyle='-';
            hlines(m).LineWidth=2;
            hlines(m).Color=cv(m,:);
        end
    end

    grid(haxes,'on');
    if isvswr
        title(haxes,'VSWR');
        ylabel(haxes,'Magnitude');
    else
        title(haxes,'Active Return Loss');
        ylabel(haxes,'Return loss (dB)');
    end
    xlabel(haxes,['Frequency (',U,'Hz)']);
    legend(haxes,legstr,'Location','best');

    if antennashared.internal.figureForwardState(hfig)
        shg;
    end

end
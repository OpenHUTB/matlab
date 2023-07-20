function plotdatacomplex(freq,data,U,val,legstr,haxes,numelems)

    cla(haxes);
    hlines=plot(haxes,freq.',real(data(:,val)),freq.',imag(data(:,val)));

    cv=em.internal.colorvector(numelems);
    hfig=haxes.Parent;
    if isscalar(freq)
        for m=1:length(hlines)/2
            hlines(m).Marker='o';
            hlines(m).Color=cv(m,:);
            hlines(m).DisplayName=['Resistance'+" "+legstr{m}];
        end

        idx=1;
        for m=length(hlines)/2+1:length(hlines)
            hlines(m).Marker='*';
            hlines(m).Color=cv(idx,:);
            hlines(m).DisplayName=['Reactance'+" "+legstr{idx}];
            idx=idx+1;
        end
    else
        for m=1:length(hlines)/2
            hlines(m).LineStyle='-';
            hlines(m).LineWidth=2;
            hlines(m).Color=cv(m,:);
            hlines(m).DisplayName=['Resistance'+" "+legstr{m}];
        end

        idx=1;
        for m=length(hlines)/2+1:length(hlines)
            hlines(m).LineStyle='--';
            hlines(m).LineWidth=2;
            hlines(m).Color=cv(idx,:);
            hlines(m).DisplayName=['Reactance'+" "+legstr{idx}];
            idx=idx+1;
        end
    end
    grid(haxes,'on');
    xlabel(haxes,['Frequency (',U,'Hz)']);
    ylabel(haxes,'Impedance (ohms)');
    legend(haxes,'show');

    title(haxes,'Active Impedance');
    try
        if antennashared.internal.figureForwardState(hfig)&&~matlab.ui.internal.isUIFigure(hfig)
            shg;
        end
    catch
    end

end
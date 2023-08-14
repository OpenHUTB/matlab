function updateColorBar(this)



    if isempty(this.hColorBar)
        return
    end
    uiservices.setListenerEnable(this.YTickListener,false);
    uiservices.setListenerEnable(this.YLimitListener,false);
    currentAxUnits=get(this.Axes(1,2),'Units');
    set(this.Axes(1,2),'Units','normalized');
    posAx=get(this.Axes(1,2),'Position');
    posCb=get(this.hColorBar,'Position');
    height=posCb(4);
    yPos=posAx(2)+posAx(4)+height/4;
    xLength=posAx(3)/1;


    if yPos<=0||any(posAx<=0)
        set(this.hColorBar,'Visible','off');
    else
        set(this.hColorBar,'Visible','on');
        set(this.hColorBar,'Position',[posAx(1)+(posAx(3)-xLength)/2,yPos,xLength,height]);
        posCb=get(this.hColorBar,'Position');



        txtColor=get(get(this.Axes(1,2),'XLabel'),'Color');

        map=colormap(this.Axes(1,2));

        titleColor=map(end,:);
        titleColor=uiservices.getContrastColor(titleColor);

        tit=get(this.hColorBar,'Title');
        if strcmp(this.SpectrumType,'Power')

            [offset,titlestr]=getPowerOffsetAndTitleStr(this);
        elseif strcmp(this.SpectrumType,'Power density')

            [offset,titlestr]=getPowerDensityOffsetAndTitleStr(this);
        elseif strcmp(this.SpectrumType,'RMS')

            [offset,titlestr]=getRMSOffsetAndTitleStr(this);
        else
            offset=-0.035;
            titlestr='';
        end
        set(tit,'String',titlestr,'Color',titleColor,...
        'Units','normalized','FontUnits','points',...
        'Tag','SpectrumAnalyzerColorBarTitle');



        set(tit,'position',[posCb(1)+posCb(3)+offset,posCb(2)/8]);

        uistack(tit,'top');
        fs=get(this.Axes(1,2),'FontSize');
        set(this.hColorBar,'FontSize',fs);
        set(this.hColorBar,'FontName',get(this.Axes(1,2),'FontName'));
        set(this.hColorBar,'XColor',txtColor);



        pos=getpixelposition(this.hColorBar);
        pf=uiservices.getPixelFactor;
        setpixelposition(this.hColorBar,[pos(1)-1*pf,pos(2),pos(3)+2*pf,17.78*pf]);
        uistack(this.hColorBar,'top');
        set(this.Axes(1,2),'Units',currentAxUnits);
        updateTitlePosition(this);
        uiservices.setListenerEnable(this.YTickListener,this.ShowYAxisLabels);
        uiservices.setListenerEnable(this.YLimitListener,this.ShowYAxisLabels);
    end
end




function[offset,titlestr]=getPowerOffsetAndTitleStr(this)

    switch(this.AxesLayout)
    case 'Vertical'
        switch this.SpectrumUnits
        case 'dBm'
            offset=-0.030;
            titlestr=this.SpectrumUnits;
        case 'dBW'
            offset=-0.035;
            titlestr=this.SpectrumUnits;
        case 'Watts'
            offset=-0.040;
            titlestr=this.SpectrumUnits;
        case 'dBFS'
            offset=-0.040;
            titlestr=this.SpectrumUnits;
        otherwise
            offset=-0.030;
            titlestr='';
        end
    case 'Horizontal'
        switch this.SpectrumUnits
        case 'dBm'
            offset=-0.060;
            titlestr=this.SpectrumUnits;
        case 'dBW'
            offset=-0.070;
            titlestr=this.SpectrumUnits;
        case 'Watts'
            offset=-0.080;
            titlestr=this.SpectrumUnits;
        case 'dBFS'
            offset=-0.080;
            titlestr=this.SpectrumUnits;
        otherwise
            offset=-0.060;
            titlestr='';
        end
    end
end

function[offset,titlestr]=getPowerDensityOffsetAndTitleStr(this)
    switch(this.AxesLayout)
    case 'Vertical'
        switch this.SpectrumUnits
        case 'dBm'
            offset=-0.06;
            titlestr=[this.SpectrumUnits,' / Hz'];
        case 'dBW'
            offset=-0.065;
            titlestr=[this.SpectrumUnits,' / Hz'];
        case 'Watts'
            offset=-0.07;
            titlestr=[this.SpectrumUnits,' / Hz'];
        case 'dBFS'
            offset=-0.07;
            titlestr=[this.SpectrumUnits,' / Hz'];
        otherwise
            offset=-0.050;
            titlestr='';
        end
    case 'Horizontal'
        switch this.SpectrumUnits
        case 'dBm'
            offset=-0.120;
            titlestr=[this.SpectrumUnits,' / Hz'];
        case 'dBW'
            offset=-0.130;
            titlestr=[this.SpectrumUnits,' / Hz'];
        case 'Watts'
            offset=-0.140;
            titlestr=[this.SpectrumUnits,' / Hz'];
        case 'dBFS'
            offset=-0.140;
            titlestr=[this.SpectrumUnits,' / Hz'];
        otherwise
            offset=-0.110;
            titlestr='';
        end
    end
end

function[offset,titlestr]=getRMSOffsetAndTitleStr(this)
    switch(this.AxesLayout)
    case 'Vertical'
        switch this.SpectrumUnits
        case 'dBV'
            offset=-0.035;
            titlestr=this.SpectrumUnits;
        case 'Vrms'
            offset=-0.04;
            titlestr=this.SpectrumUnits;
        otherwise
            offset=-0.035;
            titlestr='';
        end
    case 'Horizontal'
        switch this.SpectrumUnits
        case 'dBV'
            offset=-0.07;
            titlestr=this.SpectrumUnits;
        case 'Vrms'
            offset=-0.08;
            titlestr=this.SpectrumUnits;
        otherwise
            offset=-0.07;
            titlestr='';
        end
    end
end

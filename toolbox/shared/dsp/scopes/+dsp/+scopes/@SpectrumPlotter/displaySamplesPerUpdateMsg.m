function displaySamplesPerUpdateMsg(this,visibleFlag,factor)




    if nargin==1
        visibleFlag=true;
    end
    if nargin<3
        factor=1;
    end
    forceReadOut=true;
    numSamps=this.SpectrumObject.getInputSamplesPerUpdate(forceReadOut);
    if isempty(numSamps)
        return
    end
    prepareAxesForMessage(this,visibleFlag);
    if~visibleFlag
        removeSamplesPerUpdateReadOut(this);
        return
    end
    numSamps=numSamps*factor;
    str=mat2str(numSamps);
    msg=getString(message('dspshared:SpectrumAnalyzer:SpectrumScopeSamplesPerUpdate',str));
    if isempty(this.SamplesPerUpdateReadOut)

        this.SamplesPerUpdateReadOut=[text(...
        'Parent',this.Axes(1,1),...
        'Units','Normalized',...
        'Interpreter','none',...
        'FontName','fixedwidth',...
        'HorizontalAlignment','center',...
        'VerticalAlignment','middle',...
        'Tag','SpectrumSamplesPerInputMsgText',...
        'Visible','off',...
        'Position',[0,0,0]),...
        text(...
        'Parent',this.Axes(1,2),...
        'Units','Normalized',...
        'Interpreter','none',...
        'FontName','fixedwidth',...
        'HorizontalAlignment','center',...
        'VerticalAlignment','middle',...
        'Tag','SpectrogramSamplesPerInputMsgText',...
        'Visible','off',...
        'Position',[0,0,0])];


        uistack(this.SamplesPerUpdateReadOut(1),'top');
        uistack(this.SamplesPerUpdateReadOut(2),'top');
    end

    this.SamplesPerUpdateMsgStatus=true;
    set(this.SamplesPerUpdateReadOut,'FontSize',14);
    txt=uiservices.lineWrap(msg,this.SamplesPerUpdateReadOut(1));
    set(this.SamplesPerUpdateReadOut,'String',txt)
    txtExtent=get(this.SamplesPerUpdateReadOut(1),'Extent');
    contFlag=true;
    fs=14;

    if strcmpi(this.PlotMode,'SpectrumAndSpectrogram')
        set(this.SamplesPerUpdateReadOut,'Visible','on');
    elseif strcmpi(this.PlotMode,'Spectrogram')
        set(this.SamplesPerUpdateReadOut(1),'Visible','off');
        set(this.SamplesPerUpdateReadOut(2),'Visible','on');
    else
        set(this.SamplesPerUpdateReadOut(1),'Visible','on');
        set(this.SamplesPerUpdateReadOut(2),'Visible','off');
    end

    while txtExtent(4)>0.40&&contFlag
        fs=fs-2;
        set(this.SamplesPerUpdateReadOut,'FontSize',fs)
        txt=uiservices.lineWrap(msg,this.SamplesPerUpdateReadOut(1));
        set(this.SamplesPerUpdateReadOut,'String',txt)
        txtExtent=get(this.SamplesPerUpdateReadOut(1,1),'Extent');
        if fs<6
            contFlag=false;
        end
    end
    [~,textColorSpectrum]=getLegendColors(this);
    set(this.SamplesPerUpdateReadOut(1),'Position',[0.5,0.5]);
    set(this.SamplesPerUpdateReadOut(1),'Color',textColorSpectrum);
    set(this.SamplesPerUpdateReadOut(1),'BackgroundColor',get(this.Axes(1,1),'Color'));

    set(this.SamplesPerUpdateReadOut(2),'Position',[0.5,0.5]);
    set(this.SamplesPerUpdateReadOut(2),'Color',textColorSpectrum);
    set(this.SamplesPerUpdateReadOut(2),'BackgroundColor',get(this.Axes(1,2),'Color'));

end

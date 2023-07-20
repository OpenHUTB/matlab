function updateNoDataAvailableMessage(this,visibleFlag)




    if nargin==1

        if isempty(this.NoDataAvailableTxt)
            return
        end
        visibleFlag=true;
    end
    hPlotter=this.Plotter;

    isInitMode=this.IsInitModeFlag;
    if~isempty(hPlotter)
        prepareAxesForMessage(hPlotter,visibleFlag);
    end
    if~visibleFlag


        if~isempty(this.NoDataAvailableTxt)
            delete(this.NoDataAvailableTxt);
            this.NoDataAvailableTxt=[];
        end
        updateSpectralMask(this);
        return
    end

    notify(this,'InvalidateMeasurements');
    hSpec=this.Application.Specification;
    if isInitMode
        id='Spcuilib:scopes:ErrorDataNotAvailableSystemObject';
        msg=getString(message(id,'dsp.SpectrumAnalyzer'));
        if~isempty(hSpec)&&isa(hSpec,'spbscopes.SpectrumAnalyzerBlockCfg')
            id='Spcuilib:scopes:ErrorNoDataUntilSimulinkStarts';
            msg=getString(message(id));
        end
    else
        id='dspshared:SpectrumAnalyzer:SpectrumScopeNoDataAvailableMsgSysObj';
        if~isempty(hSpec)&&isa(hSpec,'spbscopes.SpectrumAnalyzerBlockCfg')
            id='dspshared:SpectrumAnalyzer:SpectrumScopeNoDataAvailableMsgSL';
        end
        msg=getString(message(id));
    end

    hAxes=this.Axes;
    if isempty(this.NoDataAvailableTxt)

        this.NoDataAvailableTxt=[text('Parent',hAxes(1,1),...
        'Tag','SpectrumNoDataAvailableMsgText',...
        'Units','norm','Interpreter','none',...
        'String','','FontName','fixedwidth',...
        'UserData','','BackgroundColor','none','Visible','off'),...
        text('Parent',hAxes(1,2),...
        'Tag','SpectrogramNoDataAvailableMsgText',...
        'Units','norm','Interpreter','none',...
        'String','','FontName','fixedwidth',...
        'UserData','','BackgroundColor','none','Visible','off')];
        uistack(this.NoDataAvailableTxt(1),'top');
        uistack(this.NoDataAvailableTxt(2),'top');
    end
    hNoDataAvailableTxt=this.NoDataAvailableTxt;


    blankSpectrogram(this,true);
    textPos=[0.5,0.5];
    maxExtent=0.4;
    hAlignment='center';
    vAlignment='middle';
    initFontSize=14;
    set(hNoDataAvailableTxt,'Position',textPos);
    set(hNoDataAvailableTxt,'HorizontalAlignment',hAlignment);
    set(hNoDataAvailableTxt,'VerticalAlignment',vAlignment);


    set(hNoDataAvailableTxt,'FontSize',initFontSize);
    txt=uiservices.lineWrap(msg,hNoDataAvailableTxt(1),'Axes');
    set(hNoDataAvailableTxt,'String',txt);
    txtExtent=get(hNoDataAvailableTxt(1),'Extent');
    contFlag=true;

    while txtExtent(4)>maxExtent&&contFlag
        fs=get(hNoDataAvailableTxt(1),'FontSize')-2;
        set(hNoDataAvailableTxt,'FontSize',fs)
        txt=uiservices.lineWrap(msg,hNoDataAvailableTxt(1));
        set(hNoDataAvailableTxt,'String',txt)
        txtExtent=get(hNoDataAvailableTxt(1),'Extent');
        if fs<6
            set(hNoDataAvailableTxt,'Visible','off');
            contFlag=false;
        end
    end


    if isCombinedViewMode(this)
        axesVisibility={true;true};
    elseif isSpectrogramMode(this)
        axesVisibility={false;true};
    else
        axesVisibility={true;false};
    end
    if axesVisibility{1}
        bgColorSpectrum=get(hAxes(1,1),'Color');
        textColorSpectrum=uiservices.getContrastColor(bgColorSpectrum);
        set(hNoDataAvailableTxt(1),'Color',textColorSpectrum);
        set(hNoDataAvailableTxt(1),'BackgroundColor',bgColorSpectrum);
        set(hNoDataAvailableTxt(1),'Visible','on');
    else
        set(hNoDataAvailableTxt(1),'Visible','off');
    end
    if axesVisibility{2}
        map=colormap(ancestor(hAxes(1,2),'Figure'));
        bgColorSpectrogram=map(1,:);
        textColorSpectrogram=uiservices.getContrastColor(bgColorSpectrogram);
        set(hNoDataAvailableTxt(2),'Color',textColorSpectrogram);
        set(hNoDataAvailableTxt(2),'BackgroundColor',bgColorSpectrogram);
        set(hNoDataAvailableTxt(2),'Visible','on');
    else
        set(hNoDataAvailableTxt(2),'Visible','off');
    end


    if~isempty(hPlotter)
        updateXAxisLabels(hPlotter,isCCDFMode(this));


        hXLabelSpectrum=get(hAxes(1),'XLabel');
        hXLabelSpectrogram=get(hAxes(2),'XLabel');

        if isCCDFMode(this)

            set(hXLabelSpectrum,'String',uiscopes.message('DBOverAveragePowerXLabel'));
            set(hXLabelSpectrum,'Visible','on');
            set(hXLabelSpectrogram,'Visible','off');
        elseif~isCombinedViewMode(this)&&~isSpectrogramMode(this)

            set(hXLabelSpectrum,'String',uiscopes.message('FrequencyXLabel'));
            set(hXLabelSpectrum,'Visible','on');
            set(hXLabelSpectrogram,'Visible','off');
        elseif isSpectrogramMode(this)

            set(hXLabelSpectrogram,'String',uiscopes.message('FrequencyXLabel'));
            set(hXLabelSpectrum,'Visible','off');
            set(hXLabelSpectrogram,'Visible','on');
        else

            set(hXLabelSpectrum,'String',uiscopes.message('FrequencyXLabel'));
            set(hXLabelSpectrum,'Visible','on');
            set(hXLabelSpectrogram,'String',uiscopes.message('FrequencyXLabel'));
            set(hXLabelSpectrogram,'Visible','on');
        end

        updateInset(this);
        updateColorBar(this);
        updateSpectralMask(this);
    end
end

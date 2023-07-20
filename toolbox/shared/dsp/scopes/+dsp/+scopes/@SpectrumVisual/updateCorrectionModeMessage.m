function updateCorrectionModeMessage(this,visibleFlag,errorMsg)




    if this.IsVisualStartingUp
        return
    end
    if nargin<2
        visibleFlag=getPropertyValue(this,'IsCorrectionMode');
    end
    if nargin<3
        errorMsg=[];
    end

    if~isempty(errorMsg)
        str=errorMsg;
    elseif~isempty(this.CorrectionModeTxt)
        str=get(this.CorrectionModeTxt,'String');
        str=unwrapStr(str);
    end

    hPlotter=this.Plotter;
    if~isempty(hPlotter)
        prepareAxesForMessage(hPlotter,visibleFlag);
    end


    if~isempty(this.CorrectionModeTxt)
        delete(this.CorrectionModeTxt);
        this.CorrectionModeTxt=[];
        delete(this.CorrectionModeAxes);
        this.CorrectionModeAxes=[];
    end

    if~visibleFlag
        updateSpectralMask(this);
        return
    end

    notify(this,'InvalidateMeasurements');
    hAxes=this.Axes(1,1);
    hParent=get(this.Axes(1,1),'Parent');
    pos=get(hParent,'Position');



    this.CorrectionModeAxes=axes('Parent',hParent);
    set(this.CorrectionModeAxes,'Position',pos);
    set(this.CorrectionModeAxes,'YTick',[]);
    set(this.CorrectionModeAxes,'XTick',[]);
    set(this.CorrectionModeAxes,'Color',get(this.Axes(1,1),'Color'))
    set(this.CorrectionModeAxes,'Layer','Top');

    this.CorrectionModeTxt=text('Parent',this.CorrectionModeAxes,...
    'Position',[.5,.5],'Tag','CorrectionMssgText',...
    'Units','norm','HorizontalAlignment','center',...
    'VerticalAlignment','middle','Interpreter','none',...
    'String','','FontName','fixedwidth',...
    'UserData','','Visible','on');

    set(this.CorrectionModeTxt,'FontSize',14);

    msg=str;
    txt=uiservices.lineWrap(msg,this.CorrectionModeTxt,'Axes');
    set(this.CorrectionModeTxt,'String',txt);
    txtExtent=get(this.CorrectionModeTxt,'Extent');
    contFlag=true;

    while txtExtent(4)>0.40&&contFlag
        fs=get(this.CorrectionModeTxt,'FontSize')-2;
        set(this.CorrectionModeTxt,'FontSize',fs)
        txt=uiservices.lineWrap(msg,this.CorrectionModeTxt);
        set(this.CorrectionModeTxt,'String',txt)
        txtExtent=get(this.CorrectionModeTxt,'Extent');
        if fs<6
            contFlag=false;
        end
    end
    textColor=get(hAxes,'XColor');
    bgColor=get(hAxes,'Color');
    if isequal(bgColor,[0,0,0])
        textColor=textColor.^(1/3);
        textColor(textColor==0)=.3;
    end
    set(this.CorrectionModeTxt,'Position',[.5,.5]);
    set(this.CorrectionModeTxt,'Color',textColor);
    set(this.CorrectionModeTxt,'BackgroundColor',get(this.Axes(1,1),'Color'))
    uistack(this.CorrectionModeTxt,'top')
    if~isempty(hPlotter)
        updateSpectralMask(this);
    end
end

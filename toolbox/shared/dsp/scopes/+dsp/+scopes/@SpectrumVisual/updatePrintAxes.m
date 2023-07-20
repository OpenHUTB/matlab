function updatePrintAxes(this,inputFig)






    if isempty(inputFig)
        return
    end
    hColorBar=[];


    sendEvent(this.Application,'FigurePrinted');
    printAxes=get(inputFig,'Children');


    guiExt=getExtInst(this.Application,'Core','General UI');
    bgndColor=getPropertyValue(guiExt,'FigureColor');
    set(inputFig,'Color',bgndColor);
    isSpectrogram=isSpectrogramMode(this);
    isCombinedView=isCombinedViewMode(this);


    if(strcmp(get(this.Axes(1,1),'Visible'),'on'))||(strcmp(get(this.Axes(1,2),'Visible'),'on'))
        if~isSpectrogram&&~isCombinedView

            setSpectrumPrintAxis(this,printAxes,1);
        elseif isSpectrogram

            hColorBar=setSpectrogramPrintAxis(this,printAxes,1);
        else

            setSpectrumPrintAxis(this,printAxes,1);
            hColorBar=setSpectrogramPrintAxis(this,printAxes,2);
        end
        set(inputFig,'Units','Pixels');
        inputFigPos=get(inputFig,'Position');
        set(printAxes,'Units','Pixels');
        printAxesPosSpectrum=get(printAxes(1,1),'Position');

        offset=10;
        set(inputFig,'Position',[inputFigPos(1:3),inputFigPos(4)+offset]);
        set(printAxes,'Position',[printAxesPosSpectrum(1),printAxesPosSpectrum(2)+...
        offset+offset/2,printAxesPosSpectrum(3),printAxesPosSpectrum(4)-offset]);
        if isCombinedView
            printAxesPosSpectrogram=get(printAxes(2,1),'Position');
            set(printAxes(2,1),'Position',[printAxesPosSpectrogram(1),printAxesPosSpectrogram(2)+...
            offset+offset/2,printAxesPosSpectrogram(3),printAxesPosSpectrogram(4)-offset]);
        end
        set(inputFig,'Units','Normalized');

        hRBWReadout=this.Handles.RBWStatus;
        hPrintReadout=copy(hRBWReadout,inputFig);
        set(hPrintReadout,'Color',get(get(this.Axes(1,1),'XLabel'),'Color'))
        txt=get(hPrintReadout,'String');

        hSampleRateReadout=this.Handles.SampleRateStatus;
        txt=[txt,', ',get(hSampleRateReadout,'Text')];
        if isSpectrogram||isCombinedView

            txt=[txt,', ',get(this.Handles.TimeResolutionStatus,'Text')];
            txt=[txt,', ',get(this.Handles.TimeOffsetStatus,'Text')];
            cbOrigUnits=get(hColorBar,'Units');
            set(hColorBar,'Units','Pixels');
            cbPos=get(hColorBar,'Position');
            set(hColorBar,'Position',cbPos(1:4));
            set(hColorBar,'Units',cbOrigUnits);
        end
        addReadouts=strcmpi(hRBWReadout.Visible,'on');
        set(hPrintReadout,'String',txt,'Visible',hRBWReadout.Visible,...
        'Tag','StatusBarReadoutText');

        noDataMsg=findall(inputFig,'type','text','tag','SpectrumNoDataAvailableMsgText');
        correctionMsg=findall(inputFig,'type','text','tag','CorrectionMssgText');
        samplesPerUpdateMsg=findall(inputFig,'type','text','tag','SpectrumSamplesPerInputMsgText');
        set([noDataMsg,correctionMsg,samplesPerUpdateMsg],'BackgroundColor','none');

        axesLayout=this.pAxesLayout;
        set(inputFig,'ResizeFcn',@(~,~)onResizePrintAxes(inputFig,...
        printAxes,isSpectrogram,isCombinedView,axesLayout,hColorBar,addReadouts));
        if~isempty(resetplotview(printAxes,'GetStoredViewStruct'))
            zoom(printAxes,'reset');
        end
    end
end



function setSpectrumPrintAxis(this,printAxes,printAxisIdx)

    set(printAxes(printAxisIdx),'YTickMode','auto');
    set(printAxes(printAxisIdx),'YTickLabelMode','auto');

    lines=[this.Plotter.Lines,this.Plotter.MaxHoldTraceLines,this.Plotter.MinHoldTraceLines];

    if~isempty(lines)

        printLines=findall(printAxes(printAxisIdx),'type','line');
        if~isCCDFMode(this)
            XData=get(lines(1),'XData')*this.Plotter.FrequencyMultiplier;
            for idx=1:length(printLines)
                set(printLines(idx),'XData',XData);
            end
        end
    end
    if~isempty(this.Plotter.MaskPlotter)
        masks=this.Plotter.MaskPlotter.MaskPatches;
        if~isempty(masks)

            if~isCCDFMode(this)
                printMasks=findall(printAxes(printAxisIdx),'type','patch');
                for mIdx=1:numel(masks)
                    vertices=get(masks(mIdx),'Vertices');

                    vertices(:,1)=vertices(:,1).*this.Plotter.FrequencyMultiplier;

                    set(printMasks(mIdx),'Vertices',vertices);
                end
            end


            oldOrder=allchild(printAxes(printAxisIdx));
            newOrder=[oldOrder(end-numel(masks)+1:end);oldOrder(1:end-numel(masks))];
            printAxes(printAxisIdx).Children=newOrder;
        end
    end
    if~isempty(get(this.Axes(1,1),'XTickLabel'))
        xlim=get(printAxes(printAxisIdx),'XLim')*this.Plotter.FrequencyMultiplier;
        set(printAxes(printAxisIdx),'XLim',xlim);
        set(printAxes(printAxisIdx),'XTickMode','auto');
        set(printAxes(printAxisIdx),'XTickLabelMode','auto');
    end
    if isCCDFMode(this)&&~isempty(get(this.Axes(1,1),'YTickLabel'))
        ylim=get(printAxes(printAxisIdx),'YLim');
        set(printAxes(printAxisIdx),'YLim',ylim);
        set(printAxes(printAxisIdx),'YTickMode','auto');
        set(printAxes(printAxisIdx),'YTickLabelMode','auto');
    end
    legendVisible=getPropertyValue(this,'Legend');
    if(legendVisible)
        pos=get(this.Plotter.LegendHandle,'Position');
        txtColor=get(this.Plotter.LegendHandle,'TextColor');
        edgeColor=get(this.Plotter.LegendHandle,'EdgeColor');
        hl=legend(printAxes(printAxisIdx),'Location',pos);
        set(hl,'String',get(this.Plotter.LegendHandle,'String'));
        set(hl,'TextColor',txtColor,'EdgeColor',edgeColor);

        set(hl,'Box',get(this.Plotter.LegendHandle,'Box'));
    end
end

function hColorBar=setSpectrogramPrintAxis(this,printAxes,printAxisIdx)

    img=this.Plotter.hImage;
    if~isempty(img)&&~isempty(get(this.Axes(1,2),'XTickLabel'))&&~isempty(get(this.Axes(1,2),'YTickLabel'))
        XData=get(img,'XData')*this.Plotter.FrequencyMultiplier;
        YData=get(img,'YData')*this.Plotter.TimeMultiplier;
        printImg=findall(printAxes,'type','image');
        set(printImg,'XData',XData);
        set(printImg,'YData',YData);
        xlim=get(printAxes(printAxisIdx),'XLim')*this.Plotter.FrequencyMultiplier;
        set(printAxes(printAxisIdx),'XLim',xlim);
        set(printAxes(printAxisIdx),'XTickMode','auto');
        set(printAxes(printAxisIdx),'XTickLabelMode','auto');
        ylim=get(printAxes(printAxisIdx),'YLim')*this.Plotter.TimeMultiplier;
        set(printAxes(printAxisIdx),'YLim',ylim);
        set(printAxes(printAxisIdx),'YTickMode','auto');
        set(printAxes(printAxisIdx),'YTickLabelMode','auto');
    end

    currentCB=this.Plotter.hColorBar;
    if~isempty(currentCB)
        currentTit=get(currentCB,'Title');
        hColorBar=colorbar('peer',printAxes(printAxisIdx),'location','North');
        set(hColorBar,'Units',get(currentCB,'Units'));
        currentCBPos=get(currentCB,'Position');
        axesPos=get(printAxes(printAxisIdx),'Position');
        set(hColorBar,'Position',[axesPos(1),currentCBPos(2),axesPos(3),currentCBPos(4)]);
        set(hColorBar,'XAxisLocation',get(currentCB,'XAxisLocation'));
        set(hColorBar,'UIContextMenu',[]);
        tit=get(hColorBar,'Title');
        set(tit,'String',get(currentTit,'String'),...
        'Color',get(currentTit,'Color'),'Units','normalized',...
        'FontUnits','normalized','Position',get(currentTit,'Position'))
        uistack(tit,'top');
        fs=get(this.Axes(1,2),'FontSize');
        set(hColorBar,'FontSize',fs)
        set(hColorBar,'FontName',get(this.Axes(1,2),'FontName'))
        set(hColorBar,'XColor',get(get(this.Axes(1,2),'XLabel'),'Color'));
        currentFigTit=get(this.Axes(1,2),'Title');
        figTit=get(printAxes(printAxisIdx),'Title');
        set(figTit,'Position',get(currentFigTit,'Position'));
    end
end

function onResizePrintAxes(inputFig,printAxes,isSpectrogram,isCombinedView,axesLayout,hColorBar,addReadouts)



    pf=uiservices.getPixelFactor;
    hTit=get(printAxes(1,1),'Title');
    str=get(hTit,'String');
    set(hTit,'Units','Pixels');
    insetFactor=1;
    if isSpectrogram&&ishghandle(hColorBar)
        if~isempty(str)
            insetFactor=4.1;
        else
            insetFactor=3.2;
        end
    end
    figurePosition=getpixelposition(inputFig);
    extraHeight=3.5*pf*addReadouts;
    set(printAxes,'Units','pixels');
    pixInset=15*pf;
    if~isCombinedView
        set(printAxes,'OuterPosition',[0,0,figurePosition(3:4)],...
        'LooseInset',[pixInset,pixInset*extraHeight,pixInset,pixInset*insetFactor]);
    else

        if strcmpi(axesLayout,'vertical')
            insetFactor=1;
            set(printAxes(1,1),'OuterPosition',[0,figurePosition(4)/2,figurePosition(3),figurePosition(4)/2],...
            'LooseInset',[pixInset,pixInset*extraHeight,pixInset,pixInset*insetFactor]);
            insetFactor=3.2;
            set(printAxes(2,1),'OuterPosition',[0,0,figurePosition(3),figurePosition(4)/2],...
            'LooseInset',[pixInset,pixInset*extraHeight,pixInset,pixInset*insetFactor]);
        else
            insetFactor=1;
            set(printAxes(1,1),'OuterPosition',[0,0,figurePosition(3)/2,figurePosition(4)],...
            'LooseInset',[pixInset,pixInset*extraHeight,pixInset,pixInset*insetFactor]);
            insetFactor=3.2;
            set(printAxes(2,1),'OuterPosition',[figurePosition(3)/2,0,figurePosition(3)/2,figurePosition(4)],...
            'LooseInset',[pixInset,pixInset*extraHeight,pixInset,pixInset*insetFactor]);
        end
    end
    if isSpectrogram&&ishghandle(hColorBar)
        axesPosition=get(printAxes(1,1),'Position');
        set(hColorBar,'Units','Pixels','Position',...
        [axesPosition(1),axesPosition(2)+axesPosition(4)+8.5*pf,axesPosition(3),20]);
        set(hTit,'Position',[axesPosition(1)+axesPosition(3)/2-50,axesPosition(4)+48*pf])
        set(hTit,'Units','Normalized')
    elseif isCombinedView
        axesPosition=get(printAxes(2,1),'Position');
        set(hColorBar,'Units','Pixels','Position',...
        [axesPosition(1),axesPosition(2)+axesPosition(4)+8.5*pf,axesPosition(3),20]);
        axesPosition=get(printAxes(1,1),'Position');
        set(hTit,'Position',[axesPosition(1)+axesPosition(3)/2-50,axesPosition(4)+2*pf])
        set(hTit,'Units','Normalized')
    else
        axesPosition=get(printAxes(1,1),'Position');
        set(hTit,'Position',[axesPosition(1)+axesPosition(3)/2-50,axesPosition(4)+2*pf]);
        set(hTit,'Units','Normalized')
    end

end

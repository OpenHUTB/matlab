function updateSpectrogramImageType(this,scale,domain)





    hOldImg=this.hImage;
    if~isempty(hOldImg)&&ishghandle(hOldImg)&&...
        (strcmp(this.FrequencyScale,scale)||strcmp(this.InputDomain,domain))
        X=get(hOldImg,'XData');
        Y=get(hOldImg,'YData');
        C=get(hOldImg,'CData');
        if(strcmp(scale,'Log')&&any(strcmpi(domain,{'Time','Frequency'})))||...
            strcmp(scale,'Linear')&&strcmpi(domain,'Frequency')
            hNewImg=pcolor(X,Y,C,'Parent',this.Axes(1,2));
            set(hNewImg,'LineStyle','none');
        elseif strcmp(scale,'Linear')&&strcmpi(domain,'Time')
            set(this.Axes(1,2),'XScale',scale);
            hNewImg=image(X,Y,C,'Parent',this.Axes(1,2));
        end
        set(hNewImg,'Tag','SpectrumAnalyzerImage');
        set(hNewImg,'CDataMapping','Scaled');
        set(hNewImg,'UIContextMenu',get(this.Axes(1,2),'UIContextMenu'));
        this.hImage=hNewImg;
        delete(hOldImg);
    end
end

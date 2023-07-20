function addCCDFGaussianReferenceLine(this)



    selectBehavior=uiservices.getPlotEditBehavior('select');
    hReferenceLine=this.CCDFGaussianReferenceLine;
    if isempty(hReferenceLine)||~ishghandle(hReferenceLine)
        hReferenceLine=line(0,NaN,'Parent',this.Axes(1,1));
        hgaddbehavior(hReferenceLine,selectBehavior);
        set(hReferenceLine,'Color',[1,1,1]);
        set(hReferenceLine,'DisplayName',getString(message('dspshared:SpectrumAnalyzer:GaussianReference')));
        this.CCDFGaussianReferenceLine=hReferenceLine;
    end
    xData=-61.7:0.01:31.7;
    yData=100*gammainc(10.^(xData/10),1,'upper');
    set(hReferenceLine,'XData',xData,'YData',yData,'LineStyle',':');
    uistack(hReferenceLine,'bottom');
end

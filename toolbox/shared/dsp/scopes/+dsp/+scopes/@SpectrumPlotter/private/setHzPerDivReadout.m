function setHzPerDivReadout(this)



    hAxes=this.Axes;
    xTicks=get(hAxes(1),'XTick')*this.FrequencyMultiplier;
    hzPerDivision=(xTicks(2)-xTicks(1))/this.FrequencyMultiplier;
    [hzPerDivision,freqFactor,unitsHzPerDivision]=engunits(hzPerDivision);
    str=[mat2str(hzPerDivision,5),' ',unitsHzPerDivision,'Hz/div'];
    hXLabel=get(hAxes(1),'XLabel');
    hParent=get(hXLabel,'Parent');
    fs=get(hXLabel,'FontSize');
    bg=get(hXLabel,'BackgroundColor');
    fg=get(hXLabel,'Color');
    pos=getpixelposition(hParent);
    if~isempty(this.XAxisHzPerDivReadout)
        delete(this.XAxisHzPerDivReadout);
        this.XAxisHzPerDivReadout=[];
    end
    this.XAxisHzPerDivReadout=text('Parent',hParent,...
    'FontSize',fs,...
    'BackgroundColor',bg,...
    'Color',fg,...
    'String',str,...
    'Units','Pixel',...
    'HorizontalAlignment','Left',...
    'VerticalAlignment','cap',...
    'Tag','HzPerDivText');
    txtExtent=get(this.XAxisHzPerDivReadout,'extent');
    set(this.XAxisHzPerDivReadout,'Position',[pos(3)-txtExtent(3),pos(2)-45]);



    midTick=round(numel(xTicks)/2);
    midXTickValue=xTicks(midTick)/this.FrequencyMultiplier;
    numDigits=floor(log10(abs(midXTickValue*freqFactor))+1);
    xTickLabels=num2str(xTicks',numDigits);
    midTickValue=xTickLabels(midTick,:);
    midTickValue(isspace(midTickValue))=[];
    pointFlag=contains(midTickValue,'.');
    actualNumDigits=length(midTickValue)-pointFlag;


    if actualNumDigits<numDigits
        numZeros=numDigits-actualNumDigits;
        zerosStr=repmat('0',1,numZeros);
        if pointFlag
            midTickValue=[midTickValue,zerosStr];
        else
            midTickValue=[midTickValue,'.',zerosStr];
        end
    end


    numCols=size(xTickLabels,2);
    if size(midTickValue,2)<=numCols
        xTickLabels=xTickLabels(:,1:size(midTickValue,2));
        xTickLabels(1:end,1:end)=' ';
    else
        extraCols=size(midTickValue,2)-numCols;
        xTickLabels(1:end,1:end+extraCols)=' ';
    end
    xTickLabels(midTick,:)=midTickValue;
    set(hAxes,'XTickLabel',xTickLabels);

end

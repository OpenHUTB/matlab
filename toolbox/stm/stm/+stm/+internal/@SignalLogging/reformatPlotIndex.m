function plotIndexStr=reformatPlotIndex(inputPlotIndex)




    plotIndexStr='';
    if(isempty(inputPlotIndex))
        return;
    end

    plotIndex=str2num(inputPlotIndex);%#ok<ST2NM>
    plotIndex=plotIndex(:).';
    plotIndex=unique(plotIndex);
    attributes={'nonempty','integer','real','>=',1,'<=',64};
    validateattributes(plotIndex,"numeric",attributes,'','PlotIndex');
    plotIndex=sort(plotIndex,2);
    plotIndexStr=num2str(plotIndex);
end

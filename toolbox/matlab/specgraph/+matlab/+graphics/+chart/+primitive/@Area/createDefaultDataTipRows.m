function dataTipRows=createDefaultDataTipRows(hObj)
















    dimensionNames=hObj.DimensionNames;
    xLabel=dimensionNames{1};
    yLabel=dimensionNames{2};


    yStackedRow=matlab.graphics.datatip.DataTipTextRow.empty(0,1);


    if hObj.NumPeers>1
        yStack=[yLabel,' (Stacked)'];
        yLabel=[yLabel,' (Segment)'];

        yStackedRow=dataTipTextRow(yStack,yStack);
        yRow=dataTipTextRow(yLabel,yLabel);
    else
        yRow=dataTipTextRow(yLabel,[yLabel,'Data']);
    end

    xRow=dataTipTextRow(xLabel,[xLabel,'Data']);

    dataTipRows=[xRow;yStackedRow;yRow];
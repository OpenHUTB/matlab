function dataTipRows=createDefaultDataTipRows(hObj)






    xgroup=dataTipTextRow(getString(message('MATLAB:graphics:boxchart:Position')),...
    getString(message('MATLAB:graphics:boxchart:Position')));
    numpts=dataTipTextRow(getString(message('MATLAB:graphics:boxchart:NumPoints')),...
    getString(message('MATLAB:graphics:boxchart:NumPoints')));
    numout=dataTipTextRow(getString(message('MATLAB:graphics:boxchart:NumOutliers')),...
    getString(message('MATLAB:graphics:boxchart:NumOutliers')));
    med=dataTipTextRow(getString(message('MATLAB:graphics:boxchart:Median')),...
    getString(message('MATLAB:graphics:boxchart:Median')));
    quart=dataTipTextRow(getString(message('MATLAB:graphics:boxchart:Quartiles')),...
    getString(message('MATLAB:graphics:boxchart:Quartiles')));
    whisk=dataTipTextRow(getString(message('MATLAB:graphics:boxchart:Whiskers')),...
    getString(message('MATLAB:graphics:boxchart:Whiskers')));
    notch=dataTipTextRow(getString(message('MATLAB:graphics:boxchart:Notches')),...
    getString(message('MATLAB:graphics:boxchart:Notches')));
    ydata=dataTipTextRow(getString(message('MATLAB:graphics:boxchart:OutlierValue')),...
    getString(message('MATLAB:graphics:boxchart:OutlierValue')));
    colgrp=dataTipTextRow(getString(message('MATLAB:graphics:boxchart:ColorGroup')),...
    getString(message('MATLAB:graphics:boxchart:ColorGroup')));


    dataTipRows=xgroup;
    if strcmp(hObj.GroupByColorMode,'manual')
        dataTipRows=[xgroup,colgrp];
    end
    dataTipRows=[dataTipRows,numpts,numout,med,quart,whisk,ydata];

    if strcmpi(hObj.Notch,'on')
        dataTipRows=[dataTipRows,notch];
    end
end
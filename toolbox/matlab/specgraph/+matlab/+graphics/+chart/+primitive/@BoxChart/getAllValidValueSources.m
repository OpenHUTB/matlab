function valueSources=getAllValidValueSources(hObj)




    valueSources=[string(getString(message('MATLAB:graphics:boxchart:Position')));...
    getString(message('MATLAB:graphics:boxchart:NumPoints'));...
    getString(message('MATLAB:graphics:boxchart:NumOutliers'));...
    getString(message('MATLAB:graphics:boxchart:Median'));...
    getString(message('MATLAB:graphics:boxchart:Quartiles'));...
    getString(message('MATLAB:graphics:boxchart:Whiskers'));...
    getString(message('MATLAB:graphics:boxchart:OutlierValue'))];

    if strcmp(hObj.GroupByColorMode,'manual')
        valueSources=[valueSources;getString(message('MATLAB:graphics:boxchart:ColorGroup'))];
    end

    if strcmpi(hObj.Notch,'on')
        valueSources=[valueSources;getString(message('MATLAB:graphics:boxchart:Notches'))];
    end
end

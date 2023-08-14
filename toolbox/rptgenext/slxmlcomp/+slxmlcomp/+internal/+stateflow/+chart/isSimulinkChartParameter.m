function isSLParam=isSimulinkChartParameter(chartPath,parameterName)



    isSLParam=false;
    try
        objectParameters=get_param(chartPath,'ObjectParameters');
        objectParameters.(parameterName);
        isSLParam=true;
    catch E %#ok<NASGU>
    end

end


function displaySummaryForAnalyzeNetwork(lookupid)









    cacheManager=coder.internal.AnalyzeNetworkCacheManager.instance;
    value=cacheManager.lookup(lookupid);

    if isempty(value)


        error(message('dlcoder_spkg:ValidateNetwork:HyperlinkExpired'));
    end

    fieldEnum=value{1};
    valueToDisp=value{2};
    targetLibrary=value{3};

    switch fieldEnum
    case coder.internal.AnalyzerStructFields.NetworkDiagnostics
        str=getString(message('dlcoder_spkg:ValidateNetwork:NetworkDiagnostics'));
    case coder.internal.AnalyzerStructFields.LayerDiagnostics
        str=getString(message('dlcoder_spkg:ValidateNetwork:LayerDiagnostics'));
    case coder.internal.AnalyzerStructFields.IncompatibleLayerTypes
        str=getString(message('dlcoder_spkg:ValidateNetwork:IncompatibleLayerTypes'));
    otherwise
        assert(false);
    end

    disp(getString(message('dlcoder_spkg:ValidateNetwork:SummaryHyperlinkHeader',str,targetLibrary)));
    fprintf('\n');
    disp(valueToDisp);
    fprintf('\n');


end

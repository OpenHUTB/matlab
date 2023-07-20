function prefEntry=getXYPlotPreferenceEntries(entryValue)
    switch entryValue
    case DAStudio.message('record_playback:params:YColorModelDef')
        prefEntry='record_playback:toolstrip:YAxisColor';
    case DAStudio.message('record_playback:params:XColorModelDef')
        prefEntry='record_playback:toolstrip:XAxisColor';
    case DAStudio.message('record_playback:params:TrendLineLinearModelDef')
        prefEntry='record_playback:toolstrip:XYTrendLineLinear';
    case DAStudio.message('record_playback:params:TrendLineLogarithmicModelDef')
        prefEntry='record_playback:toolstrip:XYTrendLineLogarithmic';
    case DAStudio.message('record_playback:params:TrendLinePolynomialModelDef')
        prefEntry='record_playback:toolstrip:XYTrendLinePolynomial';
    case DAStudio.message('record_playback:params:TrendLinePowerModelDef')
        prefEntry='record_playback:toolstrip:XYTrendLinePower';
    case DAStudio.message('record_playback:params:TrendLineExponentialModelDef')
        prefEntry='record_playback:toolstrip:XYTrendLineExponential';

    otherwise
        prefEntry='record_playback:toolstrip:None';
    end
end
function rtwCheckCppCompatibility(modelName)
    if slfeature('PolySpaceForCodeMetrics')
        return;
    end



    GenCPP=rtwprivate('rtw_is_cpp_build',modelName);

    if GenCPP&&coder.internal.slcoderReport('generateCodeMetricsReportOn',modelName)
        throw(MSLException([],message('RTW:report:CodeMetricsNotSupportCpp',modelName)));
    end;

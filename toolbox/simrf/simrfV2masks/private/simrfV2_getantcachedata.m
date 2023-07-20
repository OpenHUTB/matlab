function cacheData=simrfV2_getantcachedata(block)





    cacheData=get_param(block,'UserData');

    if isempty(cacheData)
        IntAntennaData.srcFreqRange='';
        IntAntennaData.srcFreqRangeUnit='';
        IntAntennaData.srcPlotFreq=[];
        IntAntennaData.AntennaIcon='GeneralAntennaIcon.png';
        IntAntennaData.AntennTypeText='<antenna type>';
        cacheData.NumPorts=1;
        cacheData.Impedance=50;
        cacheData.OrigParamType='a';
        cacheData.normFIthetaDep=[];
        cacheData.normFIphiDep=[];
        cacheData.normFIthetaArr=[];
        cacheData.normFIphiArr=[];
        cacheData.OrigAntenna=[];
        cacheData.IntAntenna=[];
        cacheData.IntAntennaData=IntAntennaData;
        cacheData.appToolGrpName=[];
        cacheData.ArrDirection=[];
        cacheData.DepDirection=[];
        cacheData.AntChangedDep=false;
        cacheData.AntChangedArr=false;
        cacheData.ZinOn=true;
        cacheData.TransAntIinMeasurementOn=true;
        cacheData.RecAntVocOn=false;

        set_param(block,'UserData',cacheData);
        set_param(block,'UserDataPersistent','on');

    end

end
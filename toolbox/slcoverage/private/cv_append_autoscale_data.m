function cv_append_autoscale_data(covData)





    try

        sigRange=covData.metrics.sigrange;


        srIsa=cv('get','default','sigranger.isa');


        topCov=cv('get',covData.rootID,'.topSlsf');


        metricEnum=cvi.MetricRegistry.getEnum('sigrange');
        [allIds,depths]=cv('DfsOrder',topCov,'require',metricEnum);%#ok<NASGU>
        origins=cv('get',allIds,'slsfobj.origin');

        for i=1:length(allIds)
            [srID,isaVal]=cv('MetricGet',allIds(i),metricEnum,'.id','.isa');


            if(origins(i)==2)&&(isaVal==srIsa)

                dataBlockName=cv('get',allIds(i),'.origPath');

                if~isempty(Simulink.ID.getLibSID(Simulink.ID.getHandle(dataBlockName)))
                    continue;
                end

                sfChartID=cv('get',allIds(i),'.handle');
                dataBlockName=Simulink.ID.getFullName(dataBlockName);



                [dataNames,dataWidths,dataNumbers,dataIDs]=cv_sf_chart_data(sfChartID);




                [~,sortI]=sort(dataNumbers);
                varCnt=length(dataNames);
                dataNumbers=0:(varCnt-1);
                dataNames=dataNames(sortI);
                dataWidths=dataWidths(sortI);
                dataIDs=dataIDs(sortI);


                [portSizes,baseIndex]=cv('get',srID,'.cov.allWidths','.cov.baseIdx');
                startIndex=[1,cumsum(2*portSizes)+1];


                dataSystem=bdroot(dataBlockName);
                dataChartName=strrep(dataBlockName,'/','_');



                for dataIndex=1:length(dataNames)



                    dataName=dataNames{dataIndex};
                    dataID=dataIDs(dataIndex);
                    dataSignalName=[dataChartName,'_',dataName,'_',num2str(dataID)];

                    dataParsedInfo=sf('DataParsedInfo',dataID);
                    if dataParsedInfo.type.fixpt.isFixpt

                        dataTypeActual=dataParsedInfo.type.baseStr;
                        dataTypeDefined='fixpt';


                        dataFixExp=dataParsedInfo.type.fixpt.exponent;
                        dataSlope=dataParsedInfo.type.fixpt.slope;
                        dataBias=dataParsedInfo.type.fixpt.bias;
                        dataNumBits=dataParsedInfo.type.fixpt.wordLength;
                        dataIsSigned=dataParsedInfo.type.fixpt.isSigned;
                        isScaledDouble=dataParsedInfo.type.fixpt.isScaledDouble;

                    else

                        dataTypeActual=dataParsedInfo.type.baseStr;
                        switch dataTypeActual
                        case{'boolean','double','single'}
                            dataTypeDefined=dataTypeActual;
                            dataobj=fixdt(dataTypeActual);
                        case{'int8','uint8','int16','uint16','int32','uint32'}
                            dataTypeDefined='fixpt';
                            dataobj=fixdt(dataTypeActual);
                            dataTypeActual='fixpt';
                        otherwise

                            continue;
                        end


                        dataFixExp=dataobj.FractionLength;
                        dataSlope=dataobj.Slope;
                        dataBias=dataobj.Bias;
                        dataNumBits=dataobj.WordLength;
                        dataIsSigned=dataobj.SignednessBool;
                        isScaledDouble=0;
                    end


                    dataRange=sigRange(baseIndex...
                    +startIndex(dataNumbers(dataIndex)+1)...
                    +(0:(2*dataWidths(dataIndex)-1)),:);
                    dataMin=dataRange(1);
                    dataMax=dataRange(2);



                    dataArchiveModeStr=get_param(dataSystem,'MinMaxOverflowArchiveMode');


                    cv('AutoscaleLog',...
                    dataSignalName,...
                    dataBlockName,...
                    dataName,...
                    dataTypeDefined,...
                    dataTypeActual,...
                    dataID,...
                    dataMin,...
                    dataMax,...
                    dataSlope,...
                    dataBias,...
                    dataFixExp,...
                    dataNumBits,...
                    dataIsSigned,...
                    dataArchiveModeStr,...
                    isScaledDouble);
                end
            end
        end
    catch MEx
        rethrow(MEx);
    end
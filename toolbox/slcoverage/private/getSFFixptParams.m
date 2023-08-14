function[isFixpt,dataFixExp,dataSlope,dataBias]=getSFFixptParams(chartInstanceHandle,cvDataNumbers)



    try
        numberOfData=numel(cvDataNumbers);
        isFixpt=zeros(1,numberOfData);
        dataFixExp=zeros(1,numberOfData);
        dataSlope=zeros(1,numberOfData);
        dataBias=zeros(1,numberOfData);
        chartId=sf('Private','block2chart',chartInstanceHandle);
        chartDataIds=sf('DataIn',chartId);
        for idx=1:numberOfData
            dataNum=cvDataNumbers(idx);

            isFixpt(idx)=0;
            dataFixExp(idx)=0;
            dataSlope(idx)=0;
            dataBias(idx)=0;

            if dataNum<9999
                dataID=chartDataIds(dataNum+1);
                dataParsedInfo=sf('DataParsedInfo',dataID);
                dataTypeActual=dataParsedInfo.type.baseStr;


                if dataParsedInfo.type.fixpt.isFixpt&&strcmpi(dataTypeActual,'fixpt')
                    isFixpt(idx)=1;
                    dataFixExp(idx)=dataParsedInfo.type.fixpt.exponent;
                    dataSlope(idx)=dataParsedInfo.type.fixpt.slope;
                    dataBias(idx)=dataParsedInfo.type.fixpt.bias;
                end
            end
        end
        if~any(isFixpt)
            isFixpt=[];
            dataFixExp=[];
            dataSlope=[];
            dataBias=[];
        end
    catch MEx
        rethrow(MEx);
    end
function computeFullScale(this)





    hSource=this.pDataSource;

    data=getData(hSource);
    rawData=data.values;

    dataType=getDataTypes(hSource);
    dataType=dataType{1};
    switch dataType
    case{'double','float'}


        this.pInputDataType=dataType;
        if~isempty(nonzeros(rawData))

            this.pInputPeakValue=abs(max(rawData(:)));
        else

            this.pInputPeakValue=1;
        end
    case{'uint8','int8','uint16','int16','uint32','int32','uint64','int64'}


        this.pInputDataType=dataType;
        this.pInputRange=double(intmax(dataType));
    case 'embedded.fi'


        rawData=getRawData(hSource);
        rawData=rawData{:};
        this.pInputDataType=dataType;
        range=rawData.range;
        this.pInputRange=double(range(2));
    end
    if strcmpi(getPropertyValue(this,'FullScaleSource'),'Auto')


        if any(strcmp(this.pInputDataType,{'double','float'}))
            this.pFullScale=this.pInputPeakValue;
        else
            this.pFullScale=this.pInputRange;
        end
    end
end

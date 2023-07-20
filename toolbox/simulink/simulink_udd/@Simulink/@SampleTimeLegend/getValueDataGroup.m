function valueDataGroup=getValueDataGroup(this,legendData,tabIdx,showAnnotations)



    numTs=length(legendData);
    valueDataGroup=cell(1,numTs);


    for tsIdx=1:numTs

        [valData,valDataInv]=this.getValueStringAllowInv(this,legendData(tsIdx),showAnnotations,tabIdx);

        if~iscell(valData)
            valData={valData};
            valDataInv={valDataInv};
        end

        if(isequal(size(legendData(tsIdx).Value),[1,2])&&isnumeric(legendData(tsIdx).Value)...
            &&isfinite(legendData(tsIdx).Value(1))&&legendData(tsIdx).Value(1)>0)


            value=cell(1,4);
            value{1}=valData{1}.Name;
            if(legendData(tsIdx).Value(2)<=0)
                offsetStr='';
            else
                offsetStr=Simulink.SampleTimeLegend.convertNumber2String(legendData(tsIdx).Value(2));
            end
            value{2}=offsetStr;

            value{3}=valDataInv{1}.Name;

            offsetPeriodRatio=legendData(tsIdx).Value(2)/legendData(tsIdx).Value(1);
            invOffsetStr=Simulink.SampleTimeLegend.convertNumber2String(offsetPeriodRatio);
            value{4}=invOffsetStr;

            valueDataGroup{tsIdx}.Value=value;
            valueDataGroup{tsIdx}.isDiscrete=true;
        else


            valueDataGroup{tsIdx}.Value={valData{1}.Name,valDataInv{1}.Name};
            valueDataGroup{tsIdx}.isDiscrete=false;
        end

    end
end

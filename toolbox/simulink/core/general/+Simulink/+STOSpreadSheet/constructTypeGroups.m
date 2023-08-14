function typeData=constructTypeGroups(sourceobj,mRateData)
    [tmp,ind]=sort([mRateData.executionTypeIdx]);
    sortedRateByType=mRateData(ind);


    [~,~,iorigin]=unique(tmp);
    count=accumarray(iorigin,1);

    tmpData=cell(length(count),1);
    idx1=1;
    for countidx=1:length(count)
        idx2=idx1+count(countidx)-1;
        idx=idx1:idx2;
        groupRate=sortedRateByType(idx);
        tmpData{countidx}=Simulink.STOSpreadSheet.typeNode(sourceobj,groupRate,sourceobj.mSTLObj,sourceobj.mModelName,sourceobj.baseRate);
        idx1=idx2+1;
    end


    typeData=repmat(tmpData{1},length(count),1);
    for countidx=1:length(count)
        typeData(countidx)=tmpData{countidx};
    end
end


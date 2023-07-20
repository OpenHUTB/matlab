function isOk=checkDataConsistency(currData,cumData)






    isOk=true;

    currSFcnCovData=currData.sfcnCovData;
    cumSFcnCovData=cumData.sfcnCovData;
    if isempty(currSFcnCovData)||~hasData(currSFcnCovData)||isempty(cumSFcnCovData)||~hasData(cumSFcnCovData)
        return
    end

    allCurrSFcnCovData=currSFcnCovData.getAll();
    for ii=1:numel(allCurrSFcnCovData)
        currSFcnData=allCurrSFcnCovData(ii);
        cumSFcnData=cumSFcnCovData.get(currSFcnData.Name);
        if~isempty(cumSFcnData)&&~eq(currSFcnData.CodeTr,cumSFcnData.CodeTr)

            isOk=false;
            return
        end
    end

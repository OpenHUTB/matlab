function[timeVector,responseVector,groupVector,fitData,nResponse,nObservation,tfKeepAllGroups,singleGroupFitData]=sbiogetmeasureddata(pkdata,unitConversion,modelDependentVarUnits,modelTimeUnits)













    dataSource=pkdata.DataSet;




    dvWithNaNs=double(dataSource,pkdata.DependentVarLabel);
    indices=any(~isnan(dvWithNaNs),2);


    nonNaNDataSource=dataSource(indices,:);


    time=double(nonNaNDataSource,pkdata.IndependentVarLabel);
    responseMatrix=double(nonNaNDataSource,pkdata.DependentVarLabel);
    group=double(pkdata.GroupID(indices));

    if unitConversion
        time=sbiounitcalculator(pkdata.IndependentVarUnits,modelTimeUnits,time);
        for i=1:numel(modelDependentVarUnits)
            responseMatrix(:,i)=sbiounitcalculator(pkdata.DependentVarUnits{i},modelDependentVarUnits{i},responseMatrix(:,i));
        end
    end


    nObservation=size(responseMatrix,1);
    nResponse=size(responseMatrix,2);
    nGroup=max(group);

    timeMatrix=repmat(time,1,nResponse);
    groupMatrix=repmat(group,1,nResponse);


    groupIndices=findGroups(group);
    tfKeepAllGroups=isfinite(responseMatrix);
    [timeVector,stackInd]=SimBiology.fit.internal.stackGroupedMatrix(timeMatrix,groupIndices,tfKeepAllGroups);
    responseVector=responseMatrix(stackInd);
    groupVector=groupMatrix(stackInd);
    responseColumnMatrix=repmat(1:nResponse,nObservation,1);
    responseColumnVector=responseColumnMatrix(stackInd);






















































    fitData=struct('timeUnique',cell(nGroup,1),...
    'timeObserved',cell(nGroup,1),...
    'indexUniqueTimes',cell(nGroup,1),...
    'indexObservedTimes',cell(nGroup,1),...
    'observedSize',cell(nGroup,1));
    for i=1:nGroup

        tfGroup=group==i;
        nObservationI=sum(tfGroup);
        fitData(i).observedSize=[nObservationI,nResponse];
        allResponseIndex=(1:(nObservationI*nResponse))';

        iKeepGroupI=tfKeepAllGroups(tfGroup,:);
        fitData(i).indexObservedTimes=allResponseIndex(iKeepGroupI(:));


        tfGroupVector=groupVector==i;
        fitData(i).timeObserved=time(tfGroup);

        [fitData(i).timeUnique,~,n]=unique(timeVector(tfGroupVector));


        nTimeUnique=numel(fitData(i).timeUnique);
        fitData(i).indexUniqueTimes=n+nTimeUnique*(responseColumnVector(tfGroupVector)-1);
    end







    groupMatrix(~tfKeepAllGroups)=nan;
    [sortedGroupMatrix,indexSorted]=sort(groupMatrix(:));
    singleGroupFitData.indexObservedTimes=indexSorted(isfinite(sortedGroupMatrix));
    singleGroupFitData.observedSize=[nObservation,nResponse];
end

function groupIndices=findGroups(group)

    [sortedGroup,sortedGroupIndices]=sort(group);


    sortedGroupEnd=find(sortedGroup(1:end-1)~=sortedGroup(2:end));
    sortedGroupStart=[1;(sortedGroupEnd+1)];
    sortedGroupEnd(end+1)=numel(group);

    nGroups=numel(sortedGroupStart);
    groupIndices=cell(nGroups,1);
    for i=1:nGroups
        groupIndices{i}=sortedGroupIndices(sortedGroupStart(i):sortedGroupEnd(i));
    end
end


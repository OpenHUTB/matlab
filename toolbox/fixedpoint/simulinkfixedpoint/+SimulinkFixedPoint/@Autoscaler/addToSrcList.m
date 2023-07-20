function[resultAdded,numAdded]=addToSrcList(runObj,result,actualSrcIDs)





    numAdded=0;
    resultAdded={};

    for i=1:length(actualSrcIDs)

        ascalerData=runObj.getMetaData;
        if isempty(ascalerData)
            runObj.setMetaData(fxptds.AutoscalerMetaData);
            ascalerData=runObj.getMetaData;
        end



        if~actualSrcIDs{i}.isValid
            continue;
        end




        if isempty(ascalerData.getResultSetForSource(actualSrcIDs{i}))

            [oneSrcResult,isNewRes]=getOneSourceResult(actualSrcIDs{i},runObj);


            if isNewRes
                resultAdded{end+1}=oneSrcResult;%#ok<AGROW>
                numAdded=numAdded+1;
            end

            addToSetInMetaData(ascalerData,actualSrcIDs{i},oneSrcResult);
            oneSrcResult.setIsReferredByOtherActualSourceID(true);

        end


        addToSetInMetaData(ascalerData,actualSrcIDs{i},result);











        res_actualSrcIDs=result.getActualSourceIDs;
        L=length(res_actualSrcIDs);
        if L==0
            result.setActualSourceIDs(actualSrcIDs(i));
        else
            isAlreadyInList=false;
            for j=1:L
                if eq(res_actualSrcIDs{j},actualSrcIDs{i})
                    isAlreadyInList=true;
                    break;
                end
            end
            if~isAlreadyInList
                result.setActualSourceIDs(actualSrcIDs(i));
            end
        end

    end

    function[oneSrcResults,isNewRes]=getOneSourceResult(srcID,runObj)


        oneSrcResults=runObj.getResultsWithCriteriaFromArray({'UniqueIdentifier',srcID});
        if isempty(oneSrcResults)
            data=struct('Object',srcID.getObject,'ElementName',srcID.getElementName);
            oneSrcResults=runObj.createAndUpdateResult(fxptds.SimulinkDataArrayHandler(data));
            isNewRes=true;
        else
            isNewRes=false;
        end

        function addToSetInMetaData(medatada,srcID,resultList)

            set=medatada.getResultSetForSource(srcID);

            for res_i=1:length(resultList)
                res=resultList(res_i);
                if~isempty(res)&&~isa(res,'fxptds.AbstractSimulinkObjectResult')


                    resObj=res.UniqueIdentifier.getObject;
                    if isa(resObj,'Simulink.Block')&&resObj.isSynthesized
                        continue;
                    end

                    set(res.UniqueIdentifier.UniqueKey)=res;
                end
            end
            if~isempty(set)
                medatada.setResultSetForSource(srcID,set);
            end





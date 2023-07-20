
function updateResults(coveng,cvdataObj)


    resultSettings=coveng.resultSettings;
    if resultSettings.enableCumulative
        [~,initCum]=cvi.TopModelCov.cvResults(coveng.topModelH,'getLoaded');
        if isa(cvdataObj,'cv.cvdatagroup')
            allNames=cvdataObj.allNames;
            cCumCvd=[];
            for idx=1:numel(allNames)
                cmn=allNames{idx};
                ccvd=cvdataObj.get(cmn);

                if~isempty(initCum)
                    cCumCvd=initCum.get(cmn);
                end
                update_running_total(ccvd,cCumCvd);
            end
        else
            if isa(initCum,'cv.cvdatagroup')
                initCum=[];
            end
            update_running_total(cvdataObj,initCum);
        end
    end


    function update_running_total(cvdataObj,cCumCvd)

        rootId=cvdataObj.rootID;

        oldTotalId=cv('get',rootId,'.runningTotal');
        if isempty(oldTotalId)||(oldTotalId==0)
            if~isempty(cCumCvd)
                cv('set',rootId,'.runningTotal',cCumCvd.id);
                oldTotalId=cCumCvd.id;
            end
        end
        currentRun=cvdataObj;
        if(isempty(oldTotalId)||oldTotalId==0)
            newTotal=cvdataObj;
        else
            oldTotal=cvdata(oldTotalId);
            newTotal=currentRun+oldTotal;

            newTotal=commitdd(newTotal);
        end;
        if newTotal.id==0

            newTotal=commitdd(newTotal);
        end


        cv('set',rootId,'.runningTotal',newTotal.id);
        cv('set',rootId,'.prevRunningTotal',oldTotalId);


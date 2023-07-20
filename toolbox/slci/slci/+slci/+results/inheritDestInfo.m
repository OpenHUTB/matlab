




function inheritDestInfo(obj,datamgr,Config)
    destBlks=obj.getDestSubSystems;
    numDest=numel(destBlks);
    if numDest>0


        for k=1:numDest
            destKey=destBlks{k};
            destObj=datamgr.getObject('BLOCK',destKey);



            destObj.computeStatus(Config);
            destObj.computeTraceStatus();

            destSubstatus=destObj.getSubstatus;
            if~isempty(destSubstatus)
                obj.addPrimVerSubstatus(destSubstatus);
            else



                obj.appendVerificationInfo(destObj);
            end

            otherTraceObjects=destObj.getTraceArray();
            if~isempty(otherTraceObjects)
                obj.addTraceKey(otherTraceObjects);
            end

            if~isempty(destObj.getTraceSubstatus())
                obj.addPrimTraceSubstatus(destObj.getTraceSubstatus());
            end
        end
    end
end

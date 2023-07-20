function[calleeFcnInfo,calleeMapKey]=getCalledFcnInfoWithAttributes(this,callerNode,currentIteration,callerMapKey)




    calleeFcnInfo=this.getCalledFcnInfo(callerNode);
    calleeMapKey='';
    if~isempty(calleeFcnInfo)
        calleeFcnInfo.setupCurrentTreeAttributes(this,callerNode,currentIteration,callerMapKey);
    end
end

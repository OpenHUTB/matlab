function result=hiliteCandObj(this,aCIdx,aOIdx)



    result=struct('Object',[],'MemberCalls',[]);
    aObj=this.fCandidateInfo(aCIdx).Objects(aOIdx);
    hilite_system(aObj.DSM,'user1');
    result.Object=getfullname(aObj.DSM);
    result.MemberCalls={};

    hilite_system({aObj.FcnCalls.LinkedSS},'user2');
    linkedSubsys=[{},aObj.FcnCalls.LinkedSS];
    for ii=1:length(linkedSubsys)
        result.MemberCalls=[result.MemberCalls;{getfullname(linkedSubsys{ii})}];
    end

    hilite_system(aObj.GetCalls,'user2');
    getFcnCalls=[{},aObj.GetCalls];
    for ii=1:length(getFcnCalls)
        result.MemberCalls=[result.MemberCalls;{getfullname(getFcnCalls{ii})}];
    end

    hilite_system(aObj.SetCalls,'user2');
    setFcnCalls=[{},aObj.SetCalls];
    for ii=1:length(setFcnCalls)
        result.MemberCalls=[result.MemberCalls;{getfullname(setFcnCalls{ii})}];
    end
end

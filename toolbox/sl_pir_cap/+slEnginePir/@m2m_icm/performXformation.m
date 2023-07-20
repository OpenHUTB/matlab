function errMsg=performXformation(this)



    errMsg=[];
    thisPortMap=containers.Map('KeyType','char','ValueType','any');
    this.fIcmCls2IdxMap=containers.Map('KeyType','char','ValueType','double');
    this.fIcmObj2IdxMap=containers.Map('KeyType','char','ValueType','any');
    this.fSS2FcnCallMap=containers.Map('KeyType','char','ValueType','any');
    this.fXformedInfo=struct('Class',{},'ClassMdlRef',{},'MemberFcns',{},'Objects',{});
    numCls=0;
    for cIdx=1:length(this.fCandidateInfo)
        numCls=this.genClassMdl(cIdx,numCls,thisPortMap);
        numObj=0;
        for OIdx=1:length(this.fCandidateInfo(cIdx).Objects)
            numObj=this.genObject(cIdx,OIdx,numCls,numObj,thisPortMap);
        end
    end
end

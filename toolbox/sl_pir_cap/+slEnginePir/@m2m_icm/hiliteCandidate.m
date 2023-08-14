function result=hiliteCandidate(this,Arg1,Arg2)



    result=[];
    this.clearAllHilite;
    if nargin==2
        try
            sid=Simulink.ID.getSID(Arg1);
            if isKey(this.fObj2IdxMap,sid)
                oIdx=this.fObj2IdxMap(sid);
                objInfo=this.fCandidateInfo(oIdx(1)).Objects(oIdx(2));
                if strcmpi(get_param(sid,'BlockType'),'DataStoreMemory')||isempty(objInfo.DSM)
                    result=hiliteMethod(objInfo);
                else
                    result=getfullname(objInfo.DSM);
                    hilite_system(objInfo.DSM,'user2');
                end
            end
        catch
            cIdx=-1;
            if(isa(Arg1,'char')&&isKey(this.fCls2IdxMap,Arg1))
                cIdx=this.fCls2IdxMap(Arg1);
            elseif Arg1==uint8(Arg1)&&Arg1<=length(this.fCandidateInfo)
                cIdx=Arg1;
            end

            if(cIdx>0)
                clsInfo=this.fCandidateInfo(cIdx);
                result={};
                instances=[{},clsInfo.Objects.DSM];
                hilite_system(instances,'user2');
                for ii=1:length(instances)
                    result=[result;{getfullname(instances{ii})}];%#ok
                end
            end
        end
    elseif nargin>1
        if isa(Arg1,'double')&&isa(Arg2,'double')
            try
                hiliteCandObj(this,Arg1,Arg2);
            catch
            end
        end
    end
end

function result=hiliteMethod(aObjInfo)
    result={};

    hilite_system({aObjInfo.FcnCalls.LinkedSS},'user2');
    linkedSubsys=[{},aObjInfo.FcnCalls.LinkedSS];
    for ii=1:length(linkedSubsys)
        result=[result;{getfullname(linkedSubsys{ii})}];%#ok
    end

    hilite_system(aObjInfo.GetCalls,'user2');
    getFcnCalls=[{},aObjInfo.GetCalls];
    for ii=1:length(getFcnCalls)
        result=[result;{getfullname(getFcnCalls{ii})}];%#ok
    end

    hilite_system(aObjInfo.SetCalls,'user2');
    setFcnCalls=[{},aObjInfo.SetCalls];
    for ii=1:length(setFcnCalls)
        result=[result;{getfullname(setFcnCalls{ii})}];%#ok
    end
end

function result=hiliteICM(this,Arg1,Arg2)



    result=[];
    this.clearAllHilite;
    if nargin==2
        try
            sid=Simulink.ID.getSID(Arg1);
            if isKey(this.fIcmObj2IdxMap,sid)
                oIdx=this.fIcmObj2IdxMap(sid);
                objInfo=this.fXformedInfo(oIdx(1)).Objects(oIdx(2));
                if strcmpi(get_param(sid,'BlockType'),'ModelReference')
                    result=hiliteMethod(objInfo);
                else
                    result=getfullname(objInfo.ObjMdlRef);
                    hilite_system(objInfo.ObjMdlRef,'user2');
                end
            end
        catch
            cIdx=-1;
            if(isa(Arg1,'char')&&isKey(this.fIcmCls2IdxMap,Arg1))
                cIdx=this.fIcmCls2IdxMap(Arg1);
            elseif Arg1==uint8(Arg1)&&Arg1<=length(this.fXformedInfo)
                cIdx=Arg1;
            end

            if(cIdx>0)
                clsInfo=this.fXformedInfo(cIdx);
                result={};
                instances=[{},clsInfo.Objects.ObjMdlRef];
                hilite_system(instances,'user2');
                for ii=1:length(instances)
                    result=[result;{getfullname(instances{ii})}];%#ok
                end
            end
        end
    elseif nargin>1
        if isa(Arg1,'double')&&isa(Arg2,'double')
            try
                hiliteXformedObj(this,Arg1,Arg2);
            catch
            end
        end
    end
end

function result=hiliteMethod(aObjInfo)
    result={};

    hilite_system(aObjInfo.FcnCalls,'user2');
    for ii=1:length(aObjInfo.FcnCalls)
        result=[result;{getfullname(aObjInfo.FcnCalls{ii})}];%#ok
    end
end

function result=hiliteXformedObj(this,aCIdx,aOIdx)
    result=struct('Object',[],'MemberCalls',[]);
    aObj=this.fXformedInfo(aCIdx).Objects(aOIdx);
    hilite_system(aObj.ObjMdlRef,'user1');
    result.Object=getfullname(aObj.ObjMdlRef);
    result.MemberCalls={};

    hilite_system(aObj.FcnCalls,'user2');
    for ii=1:length(aObj.FcnCalls)
        result.MemberCalls=[result.MemberCalls;{getfullname(aObj.FcnCalls{ii})}];
    end
end

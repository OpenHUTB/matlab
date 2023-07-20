function msg=excludeCls(this,aBus,aParam)



    if nargin<2
        error('At least one argument is required');
    elseif nargin<3
        paramType='';
    else
        paramType=aParam;
    end

    try
        if isa(aBus,'char')
            busName=aBus;
        else
            busName=this.fCandidateInfo(aBus).Class;
        end
        if isKey(this.fCls2IdxMap,busName)
            clsIdxMapEntry=this.fCls2IdxMap(busName);
            if isKey(clsIdxMapEntry,paramType)
                clsIdx=clsIdxMapEntry(paramType);
                this.fCandidateInfo(clsIdx).isExcluded=1;
                if isempty(paramType)
                    msg=['Class with bus ''',busName,''' is excluded.'];
                else
                    msg=['Class with bus ''',busName,''' and mask parameter type ''',paramType,''' is excluded.'];
                end
                return;
            end
        end
        if isempty(paramType)
            msg=['Class with bus ''',busName,''' is not a candidate. Nothing is excluded.'];
        else
            msg=['Class with bus ''',busName,''' and mask parameter type ''',paramType,''' is not a candidate. Nothing is excluded.'];
        end
    catch
    end
end

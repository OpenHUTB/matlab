function msg=includeCls(this,aBus,aParamType)



    if nargin<2
        error('At least one argument is required');
    elseif nargin<3
        paramType='';
    else
        paramType=aParamType;
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
                this.fCandidateInfo(clsIdx).isExcluded=0;
                if isempty(paramType)
                    msg=['Class with bus ''',busName,''' is removed from exclusion.'];
                else
                    msg=['Class with bus ''',busName,''' and mask parameter type ''',paramType,''' is removed from exclusion.'];
                end
                return;
            end
        end
        if isempty(paramType)
            msg=['Class with bus ''',busName,''' is not a candidate.'];
        else
            msg=['Class with bus ''',busName,''' and mask parameter type ''',paramType,''' is not a candidate.'];
        end
    catch
    end
end

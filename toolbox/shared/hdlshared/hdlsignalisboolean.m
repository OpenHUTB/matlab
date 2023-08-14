function boolresult=hdlsignalisboolean(idxlist)






    numSigs=size(idxlist);
    boolresult=zeros(numSigs);
    if isa(idxlist,'hdlcoder.signal')
        for ii=1:numel(idxlist)
            hT=idxlist(ii).Type;
            if hT.isArrayType
                hT=hT.BaseType;
            end
            boolresult(ii)=hT.BaseType.isBooleanType;
        end
    end

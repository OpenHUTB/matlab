function boolresult=hdlsignalisdouble(idxlist)


    numSigs=size(idxlist);
    boolresult=zeros(numSigs);
    if isa(idxlist,'handle.handle')
        if isa(idxlist,'hdlcoder.signal')
            for ii=1:numel(idxlist)
                hT=idxlist(ii).Type;
                if hT.isArrayType
                    hT=hT.BaseType;
                end
                boolresult(ii)=hT.BaseType.isDoubleType||hT.BaseType.isSingleType||hT.BaseType.isHalfType;
            end
        else

            return;
        end
    else
        sizelist=idxlist(idxlist~=0);
        sizearr=hdlsignalsizes(sizelist);

        boolresult(idxlist~=0)=(sizearr(:,1)==0)';
    end
end


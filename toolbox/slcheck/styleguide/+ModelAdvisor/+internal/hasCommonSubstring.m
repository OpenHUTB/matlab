function[status,lenActualCommonSubstring]=hasCommonSubstring(strA,strB,desiredLength)














    status=false;
    lenActualCommonSubstring=0;

    lenA=length(strA);
    lenB=length(strB);

    if desiredLength<1
        return;
    end

    if lenA<desiredLength||lenB<desiredLength
        return;
    end

    lcsMat=zeros(lenA+1,lenB+1);

    for idxA=2:lenA+1
        for idxB=2:lenB+1
            if strcmp(strA(idxA-1),strB(idxB-1))

                lcsMat(idxA,idxB)=lcsMat(idxA-1,idxB-1)+1;
                lenActualCommonSubstring=max(lenActualCommonSubstring,...
                lcsMat(idxA,idxB));

                if lenActualCommonSubstring==desiredLength
                    status=true;
                    return;
                end

            else
                lcsMat(idxA,idxB)=0;
            end
        end
    end
end


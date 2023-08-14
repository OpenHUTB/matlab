function modeVec=utilModeVecToBool(modeVec,intIndicies)




    indices_dec=sort(intIndicies,'descend');
    for i=indices_dec
        A=modeVec(1:i,:);
        B=modeVec(i,:);
        C=modeVec(i:end,:);


        largestValue=max(abs(modeVec(i,:)),[],'all');
        numDigits=length(dec2bin(largestValue));
        totalDigits=numDigits+1;

        insertRows=[];
        if(totalDigits>2)
            insertRows=zeros(totalDigits-2,size(modeVec,2));
        end
        modeVec=[A;insertRows;C];

        for j=1:numel(modeVec(1,:))
            boolMode=[(B(j)>=0);bitget(abs(B(j)),[numDigits:-1:1])'];
            modeVec(i:i+numDigits,j)=boolMode;
        end
    end
end

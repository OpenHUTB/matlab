function[slope,bias]=getParamsForRescale(minCur,maxCur,minNew,maxNew)




    range=maxCur-minCur;

    range(range==0)=1;

    slope=(maxNew-minNew)./range;
    bias=minNew+((minNew-maxNew).*minCur)./range;
end

function appendCompileCheck(h,block,dataCollectFH,postCompileCheckFH,fallbackFH)
















    if nargin<5
        fallbackFH=[];
    end

    check.block=block;
    check.dataCollectFH=dataCollectFH;
    check.postCompileCheckFH=postCompileCheckFH;
    check.fallbackFH=fallbackFH;
    check.data=[];

    h.CompileCheck(end+1)=check;
end

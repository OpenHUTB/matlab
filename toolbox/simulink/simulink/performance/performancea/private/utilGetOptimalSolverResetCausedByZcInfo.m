function compInfo=utilGetOptimalSolverResetCausedByZcInfo(model,debugText)


    compInfo={};
    if isempty(debugText)
        compInfo{1}=false;
        compInfo{2}=0;
        compInfo{3}=0;
    else

        totalZCBlkNum=regexp(debugText,'ZcInfo:(\d):\d','tokens');
        if isempty(totalZCBlkNum)
            totalZCBlkNum=0;
            totalZCBlkAffectStateNum=0;
        else
            totalZCBlkNum=str2double(totalZCBlkNum{1});
            totalZCBlkAffectStateNum=regexp(debugText,'ZcInfo:\d:(\d)','tokens');
            totalZCBlkAffectStateNum=str2double(totalZCBlkAffectStateNum{1});
        end



        if totalZCBlkNum==0
            ratio=Inf;
        else
            ratio=totalZCBlkAffectStateNum/totalZCBlkNum;
        end
        if ratio<1
            newMinimizedZC=true;
        else
            newMinimizedZC=false;
        end

        compInfo{1}=newMinimizedZC;
        compInfo{2}=totalZCBlkNum;
        compInfo{3}=totalZCBlkAffectStateNum;
    end
end


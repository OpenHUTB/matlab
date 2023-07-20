function RSIMWithSlSolver=isRSIMWithSlSolver(argToks,lModelRefInfo,lSolverType,targetType)







    RSIMWithSlSolver=false;

    hasMdlBlks=~isempty(lModelRefInfo);
    globalTiming=(strcmp(targetType,'NONE')==0)||hasMdlBlks;

    bArgs=regexprep(argToks,'^([^=]+)=.*','$1');
    bArgVals=regexprep(argToks,'^[^=]+=?(.*)$','$1');


    [tf,idx]=ismember('RSIM_SOLVER_SELECTION',bArgs);
    if(tf&&isequal(bArgVals{idx},'1'))
        if strcmp(lSolverType,'VariableStep')
            RSIMWithSlSolver=true;
        elseif globalTiming
            RSIMWithSlSolver=true;
        end
    elseif(tf&&isequal(bArgVals{idx},'2'))
        RSIMWithSlSolver=true;
    end

end


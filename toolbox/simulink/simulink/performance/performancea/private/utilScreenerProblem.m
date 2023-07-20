function[problemsList,screenerError]=utilScreenerProblem(fileName)











    problemsList='';
    screenerError=false;

    fileList=which(fileName);

    if isempty(fileList)||...
        fileList(end)=='p'
        return;
    end

    screenerInfo=coder.screener(fileList);
    problems=screenerInfo.getProblemsByImpact();

    if~isempty(problems)
        screenerError=true;
        problemsList=char(problems.join(', '));
        return;
    end
end

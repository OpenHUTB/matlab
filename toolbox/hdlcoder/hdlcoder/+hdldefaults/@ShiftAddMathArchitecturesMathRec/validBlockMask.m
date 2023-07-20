function v=validBlockMask(~,slbh)




    v=true;
    if slbh<0
        return;
    end
    functionName=get_param(slbh,'Function');

    if(~strcmpi(functionName,'Reciprocal'))
        v=false;
    end

    isMathRecipNR=strcmpi(functionName,'Reciprocal')&&strcmpi(get_param(slbh,'AlgorithmMethod'),'Newton-Raphson');

    if isMathRecipNR
        v=false;
    end

end
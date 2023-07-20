function[funh,totalParens]=visitFunctionWrapper(visitor,fcnWrapper)





    Inputs=fcnWrapper.Inputs;
    nInputs=numel(Inputs);

    inputStr=strings(nInputs,1);
    totalParens=1;




    oldReset=visitor.Reset;
    visitor.Reset=false;
    for i=1:nInputs
        inputi=Inputs{i};

        visitForest(visitor,inputi);



        [inputStr(i),numParensi]=getArgumentName(visitor,totalParens);
        totalParens=totalParens+numParensi;


        visitor.Head=visitor.Head-1;
    end



    funh=compileNonlinearFunctionAtInputs(visitor,fcnWrapper,inputStr);

    visitor.Reset=oldReset;
end

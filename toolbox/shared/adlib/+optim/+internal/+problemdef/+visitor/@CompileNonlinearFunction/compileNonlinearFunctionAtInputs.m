function funh=compileNonlinearFunctionAtInputs(visitor,fcnWrapper,inputStr)






    if~fcnWrapper.Reuse||visitor.ForDisplay

        [funh,funCallBody]=compileFunctionCall(fcnWrapper,inputStr,visitor);
        addToExprBody(visitor,funCallBody);
    else



        funName=getCompiledWithReuseName(fcnWrapper);



        if isfield(visitor.Subfun,funName)


        else


            compileRepeatedSubfunction(visitor,fcnWrapper,funName);
        end



        if visitor.InMemory





            tempFunName=getCompiledName(fcnWrapper)+"_handle";
            declareFun=...
            tempFunName+" = builtin('_GetFunctionHandleForFullpath', 'inmem:///optim_problemdef/"+...
            visitor.InMemFolder+"/"+funName+".m');"+newline;
            addToExprBody(visitor,declareFun);
            funName=tempFunName;
        end



        funIdx=getSubfunHandle(fcnWrapper,visitor);
        funh=funName+"("+strjoin(getCompiledRepeatedFunInputs(fcnWrapper,...
        inputStr,visitor.ExtraParamsName+"("+funIdx+")"),", ")+")";

    end
end

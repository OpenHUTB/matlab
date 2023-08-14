function[compiledFun,compiledStr]=compileNonlinearOutput(nlfunstruct,objName)












    if nlfunstruct.singleLine
        compiledStr=objName+" = "+nlfunstruct.funh+';'+newline;
    else
        compiledStr=sprintf(nlfunstruct.funh,objName)+newline;
    end

    fcnBody=nlfunstruct.fcnBody;
    if strlength(fcnBody)>0
        compiledFun=fcnBody+newline+compiledStr;
    else
        compiledFun=compiledStr;
    end

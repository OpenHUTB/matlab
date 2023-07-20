function[outStr,extraParamsStr,displayEntrywise,nzIdx]=expandNonlinearStr(expr,showExtraParamsLink)
















    if nargin<2
        showExtraParamsLink=true;
    end



    extraParamsName=matlab.lang.makeUniqueStrings("extraParams",...
    fieldnames(getVariables(expr)),namelengthmax);



    nlfunStruct=compileNonlinearFunction(expr,...
    'ExtraParamsName',extraParamsName,'ForDisplay',true);


    treeStr=nlfunStruct.treeStr;


    displayEntrywise=~isempty(treeStr);

    if displayEntrywise

        outStr=treeStr;

        extraParamsStr={};

        nzIdx=strlength(treeStr)>0;
    else
        if nlfunStruct.singleLine

            exprStr=nlfunStruct.funh;
        else




            exprStr=replace(nlfunStruct.funh,"%s = ","");



            exprStr=replace(exprStr,'%s','argout');


            exprStr=replace(exprStr,";","");
        end

        fcnBody=nlfunStruct.fcnBody;
        if strlength(fcnBody)>0

            fcnBody="  "+regexprep(fcnBody,'\n','\n  ');


            outStr=exprStr+newline+newline+"where:"+newline+newline+fcnBody;
        else
            outStr=exprStr;
        end


        extraParamsStr=optim.internal.problemdef.display.writeExtraParams(...
        nlfunStruct.extraParams,showExtraParamsLink);


        nzIdx=[];
    end

end

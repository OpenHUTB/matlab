function[conStr,extraParamsStr,displayEntrywise,nzIdx]=expandNonlinearStr(con,showExtraParamsLink)
















    if nargin<2
        showExtraParamsLink=true;
    end



    extraParamsName=matlab.lang.makeUniqueStrings("extraParams",...
    fieldnames(getVariables(con)),namelengthmax);


    nlfunStruct=compileNonlinearFunction(con.Expr1,...
    'ExtraParamsName',extraParamsName,'ForDisplay',true);

    fcnBody1=nlfunStruct.fcnBody;
    singleLine1=nlfunStruct.singleLine;
    funh1=nlfunStruct.funh;
    treeStr1=nlfunStruct.treeStr;


    nlfunStruct=compileNonlinearFunction(con.Expr2,...
    'ExtraParams',nlfunStruct.extraParams,'ExtraParamsName',extraParamsName,'ForDisplay',true);

    fcnBody2=nlfunStruct.fcnBody;
    singleLine2=nlfunStruct.singleLine;
    funh2=nlfunStruct.funh;
    treeStr2=nlfunStruct.treeStr;




    emptyStr1=isempty(treeStr1);
    emptyStr2=isempty(treeStr2);
    displayEntrywise=~emptyStr1&&~emptyStr2;

    if displayEntrywise

        zeroStr1=strlength(treeStr1)==0;
        zeroStr2=strlength(treeStr2)==0;
        displayEntries=~zeroStr1|~zeroStr2;
        treeStr1(displayEntries&zeroStr1)="0";
        treeStr2(displayEntries&zeroStr2)="0";


        conStr=treeStr1+" "+string(con.Relation)+" "+treeStr2;

        extraParamsStr={};

        nzIdx=strlength(treeStr1)>0&strlength(treeStr2)>0;
    else

        if strlength(fcnBody1)>0
            lhsStr="arg_LHS";
            if singleLine1
                fcnBody1=fcnBody1+newline+lhsStr+" = "+funh1+";"+newline;
            else
                fcnBody1=fcnBody1+newline+sprintf(funh1,lhsStr)+newline;
            end
        else
            [lhsStr,fcnBody1]=iAddArgumentName("arg_LHS",funh1,singleLine1);
        end

        if strlength(fcnBody2)>0
            rhsStr="arg_RHS";
            if singleLine2
                fcnBody2=fcnBody2+newline+rhsStr+" = "+funh2+";"+newline;
            else
                fcnBody2=fcnBody2+newline+sprintf(funh2,rhsStr)+newline;
            end
        else
            [rhsStr,fcnBody2]=iAddArgumentName("arg_RHS",funh2,singleLine2);
        end

        conStr=lhsStr+" "+string(con.Relation)+" "+rhsStr;

        fcnBody=strip(fcnBody1+fcnBody2);

        if strlength(fcnBody)>0

            fcnBody="    "+regexprep(fcnBody,'\n','\n    ');


            conStr=conStr+newline+newline+"   where:"+newline+newline+fcnBody;
        end

        extraParamsStr=optim.internal.problemdef.display.writeExtraParams(...
        nlfunStruct.extraParams,showExtraParamsLink);

        nzIdx=true;
    end

end

function[str,fcnBody]=iAddArgumentName(argName,funh,singleLine)

    str=funh;
    fcnBody="";
    if singleLine
        str=replace(str,";","");
    else
        str=replace(str,"%s = ","");
        if contains(str,"%s")
            fcnBody=replace(str,"%s",argName)+newline;
            str=argName;
        else
            str=replace(str,";","");
        end
    end

end

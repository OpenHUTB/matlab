function jacStr=compileVariableJacobians(obj,TotalVar)












    vars=getVariables(obj);
    varnames=string(fieldnames(vars));


    idxnames=matlab.lang.makeUniqueStrings(varnames+"idx",varnames,namelengthmax);
    jacnames=matlab.lang.makeUniqueStrings(varnames+"jac",varnames,namelengthmax);

    nVars=numel(varnames);
    if nVars==1
        varname=varnames(1);
        curVar=vars.(varname);
        varSize=size(curVar);


        if numel(varSize)>2||varSize(1)>1||varSize(2)>1

            jacStr="speye("+TotalVar+")";
        else

            jacStr="1";
        end

        initializeJacobianMemory(curVar,jacnames(1));

        jacStr=jacnames(1)+" = "+jacStr+";"+newline;
    else


        jacStr="";

        for i=1:numel(varnames)
            varname=varnames(i);
            idxname=idxnames(i);
            jacname=jacnames(i);
            curVar=vars.(varname);
            nVar=numel(curVar);






            curJacStr="sparse("+idxname+", "+1+":"+nVar...
            +", ones("+nVar+", 1), "+TotalVar+", "+nVar+")";

            initializeJacobianMemory(curVar,jacname);

            jacStr=jacStr+jacname+" = "+curJacStr+";"+newline;
        end
    end

    jacStr="% "+getString(message('shared_adlib:codeComments:CreateVariableJacobians'))+newline+...
    jacStr;

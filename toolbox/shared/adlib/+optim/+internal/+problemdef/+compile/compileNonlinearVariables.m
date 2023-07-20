function funStr=compileNonlinearVariables(obj,inputVariables)














    vars=getVariables(obj);
    varnames=string(fieldnames(vars));


    idxnames=matlab.lang.makeUniqueStrings(varnames+"idx",varnames,namelengthmax);


    idxStr="";
    varStr="";

    nVars=numel(varnames);
    if nVars==1
        varname=varnames(1);
        curVar=vars.(varname);
        varSize=size(curVar);


        if numel(varSize)>2||(varSize(1)>1&&varSize(2)>1)


            varStr=varStr+varname+" = reshape("+inputVariables+", ["+strjoin(string(size(curVar)),", ")+"]);"+newline;
        else

            varStr=varStr+varname+" = "+inputVariables;

            if varSize(2)>1

                varStr=varStr+"(:)'";

            elseif varSize(1)>1

                varStr=varStr+"(:)";
            end


            varStr=varStr+";"+newline;
        end
    else

        for i=1:numel(varnames)
            varname=varnames(i);
            idxname=idxnames(i);
            curVar=vars.(varname);
            varOffset=getOffset(curVar);
            nVar=numel(curVar);
            if nVar==1
                idx=varOffset;
            else
                idx=[varOffset,varOffset+nVar-1];
            end
            contiguousIdx=true;
            varSize=size(curVar);



            idxStr=idxStr+idxname+" = "+optim.internal.problemdef.indexing.getIndexingString(idx,contiguousIdx)+";"+newline;


            idxname="("+idxname+")";

            if numel(varSize)>2||(varSize(1)>1&&varSize(2)>1)


                varStr=varStr+varname+" = reshape("+inputVariables+idxname+", ["+strjoin(string(size(curVar)),", ")+"]);"+newline;
            else

                varStr=varStr+varname+" = "+inputVariables+idxname+";"+newline;

                if varSize(2)>1

                    varStr=varStr+varname+" = "+varname+"(:)';"+newline;

                elseif varSize(1)>1

                    varStr=varStr+varname+" = "+varname+"(:);"+newline;
                end
            end
        end


        idxStr="%% "+getString(message('shared_adlib:codeComments:VarIndices'))+newline+...
        idxStr+newline;
    end

    varStr="%% "+getString(message('shared_adlib:codeComments:MapVariables'))+newline+...
    varStr;


    funStr=idxStr+varStr;

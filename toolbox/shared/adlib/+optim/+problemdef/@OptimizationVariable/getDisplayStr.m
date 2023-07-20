function varStr=getDisplayStr(obj)





















































    varName=obj.Name;
    origVarSize=getSize(obj.VariableImpl);
    origVarIdxNames=getIndexNames(getfield(getVariables(obj),varName));
    linIdxRef=getVarIdx(obj.OptimExprImpl);

    idxStr=optim.internal.problemdef.display.getSubDisplay(linIdxRef,origVarSize,origVarIdxNames);


    varSize=getSize(obj);

    if ismatrix(obj)
        idxStr=reshape(idxStr,varSize);
        varStr=print2DVar(idxStr,varSize,varName);

    else

        NumBlocks=prod(varSize(3:end));
        BlockSize=varSize(1:2);
        idxStr=reshape(idxStr,[BlockSize,NumBlocks]);
        varStr=strings(NumBlocks*BlockSize(1),1);
        for n=1:NumBlocks

            BlockIdx=(1+(n-1)*BlockSize(1)):(n*BlockSize(1));

            blockName=idxStr(1,1,n);

            blockName=strsplit(blockName,{',',')'});

            trailingName=blockName(3:end-1);







            extraTrailingDims=numel(varSize)-2-numel(trailingName);
            if extraTrailingDims
                trailingName=strjoin([trailingName,repmat(" 1",1,extraTrailingDims-1)," "+n],',');
            else
                trailingName=strjoin(trailingName,',');
            end
            blockName="(:, :,"+trailingName+")";
            blockName=blockName+" ="+newline+newline;


            blockStr=print2DVar(idxStr(:,:,n),BlockSize,varName);
            blockStr(1)=blockName+blockStr(1);
            blockStr(end)=blockStr(end)+newline+newline;
            varStr(BlockIdx)=blockStr;
        end
    end

end

function varStr=print2DVar(idxStr,varSize,varName)



    maxLength=max(strlength(idxStr),[],1);

    midSpace=4;

    nLines=varSize(1);
    varStr=strings(nLines,1);
    for i=1:varSize(1)

        curStr="    [ "+varName+idxStr(i,1);

        for j=2:varSize(2)

            whiteSpaces=string(repmat(' ',1,midSpace+maxLength(j-1)-strlength(idxStr(i,j-1))));
            curStr=curStr+whiteSpaces+varName+idxStr(i,j);
        end
        if~isempty(j)

            whiteSpaces=string(repmat(' ',1,1+maxLength(j)-strlength(idxStr(i,j))));
        else

            whiteSpaces=string(repmat(' ',1,1+maxLength(1)-strlength(idxStr(i,1))));
        end
        varStr(i)=curStr+whiteSpaces+"]"+newline;
    end

end

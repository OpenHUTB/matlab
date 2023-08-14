function[outputStr,numParens,isArgOrVar,singleLine,forestBody]=...
    reshapeInputStr(outputName,outputSize,outputStr,numParens,isArgOrVar)





    scalarDims=outputSize==1;


    isHyperVector=sum(~scalarDims)==1;

    forestBody="";

    if all(scalarDims)

    elseif isHyperVector&&~scalarDims(1)


        if~isArgOrVar

            forestBody=outputName+" = "+outputStr+";"+newline;
            numParens=0;
        else
            outputName=outputStr;
        end
        outputStr=outputName+"(:)";
        numParens=numParens+1;
        isArgOrVar=false;
    elseif isHyperVector&&~scalarDims(2)


        if~isArgOrVar

            forestBody=outputName+" = "+outputStr+";"+newline;
            numParens=0;
        else
            outputName=outputStr;
        end
        outputStr=outputName+"(:)'";
        numParens=numParens+1;
        isArgOrVar=false;
    else


        outputStr="reshape("+outputStr+", ["+strjoin(string(outputSize),", ")+"])";
        numParens=numParens+2;
        isArgOrVar=false;
    end

    singleLine=true;

end

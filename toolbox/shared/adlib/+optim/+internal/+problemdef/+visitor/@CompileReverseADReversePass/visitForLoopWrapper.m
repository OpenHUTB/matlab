function visitForLoopWrapper(visitor,LoopWrapper)





    isOuterLoop=LoopWrapper.LoopLevel==1;
    if isOuterLoop&&visitor.Tape{end}==0

        getForwardMemory(visitor);
        nArg=getForwardMemory(visitor);
    else
        if isOuterLoop
            nArg=getForwardMemory(visitor);
            visitor.ForLoopTape=visitor.Tape(end-nArg+1:end);
            visitor.ForLoopWriteToArgTape=visitor.WriteToArgTape(end-nArg+1:end);
            visitor.Tape(end-nArg+1:end)=[];
            visitor.WriteToArgTape(end-nArg+1:end)=[];
        end


        nArg=visitor.ForLoopTape{end};
        forLoopTape=visitor.ForLoopTape(end-nArg:end-1);
        forLoopWriteToArgTape=visitor.ForLoopWriteToArgTape(end-nArg:end-1);
        visitor.Tape=[visitor.Tape,forLoopTape];
        visitor.WriteToArgTape=[visitor.WriteToArgTape,forLoopWriteToArgTape];
        visitor.ForLoopTape(end-nArg:end)=[];
        visitor.ForLoopWriteToArgTape(end-nArg:end)=[];
    end


    loopVar=LoopWrapper.LoopVar;
    loopBody=LoopWrapper.LoopBody;




    loopVarName=popNode(visitor,loopVar);

    loopVarName=extractBefore(loopVarName,"jac");
    visitor.IsNodeLHS(loopVar.VisitorIndex)=false;





    prevTape=visitor.Tape;
    prevWriteToArgTape=visitor.WriteToArgTape;

    prevBody=visitor.ExprBody;
    visitor.ExprBody="";
    acceptVisitor(loopBody,visitor);


    getForwardMemory(visitor);
    loopValuesStr=getForwardMemory(visitor);



    forloopBody=visitor.ExprBody;
    visitor.ExprBody="";

    if nArg>0
        writeToArgTape=prevWriteToArgTape(end-nArg+1:end);
        numSavedToTape=sum(writeToArgTape);
        if numSavedToTape>0
            tapeArg=prevTape(end-nArg+1:end);
            tapeArg=tapeArg(writeToArgTape);
            tapeArgName=visitor.ArgTapeName;
            tapeHeadName=visitor.ArgTapeHeadName;
            forloopBody="["+strjoin([tapeArg{:}],", ")+"] = "+...
            tapeArgName+"{("+tapeHeadName+"-"+(numSavedToTape-1)+"):"+tapeHeadName+"};"+...
            newline+tapeHeadName+" = "+tapeHeadName+" - "+numSavedToTape+";"+newline+...
            forloopBody;
        end
    end

    forloopBody=strjoin("    "+splitlines(strip(forloopBody,'right')),'\n')+newline;
    forloopBody=...
    "for "+loopVarName+" = fliplr("+loopValuesStr+")"+newline+...
    forloopBody+...
    "end"+newline;

    visitor.ExprBody=prevBody+forloopBody;
end

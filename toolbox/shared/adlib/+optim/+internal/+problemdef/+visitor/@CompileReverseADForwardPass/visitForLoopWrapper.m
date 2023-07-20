function visitForLoopWrapper(visitor,LoopWrapper)





    loopVar=LoopWrapper.LoopVar;
    loopValues=LoopWrapper.LoopRange;
    loopBody=LoopWrapper.LoopBody;




    nIter=getMaxNumIter(LoopWrapper);


    if isempty(loopVar.VisitorIndex)
        initializeNode(visitor,loopVar);

        loopVarName="arg"+visitor.getNumArgs();
        loopVarParens=0;

        pushNode(visitor,loopVar,loopVarName,loopVarParens);
    else
        loopVarName=popNode(visitor,loopVar);
    end
    visitor.IsNodeLHS(loopVar.VisitorIndex)=false;



    addParens=0;
    loopValuesStr=visitNumericExpression(visitor,loopValues,addParens);



    prevBody=visitor.ExprBody;
    visitor.ExprBody="";
    prevTapeNelem=numel(visitor.Tape);
    prevArgTapeNElem=visitor.ArgTapeTotalElem;
    visitor.ArgTapeTotalElem=0;

    acceptVisitor(loopBody,visitor);


    forloopBody=visitor.ExprBody;
    visitor.ExprBody="";
    tapeNelem=numel(visitor.Tape);
    forLoopTape=visitor.Tape(prevTapeNelem+1:tapeNelem);
    forLoopWriteToArgTape=visitor.WriteToArgTape(prevTapeNelem+1:tapeNelem);
    nArg=tapeNelem-prevTapeNelem;


    if nArg>0

        numSavedToArgTape=sum(forLoopWriteToArgTape);

        if numSavedToArgTape>0
            if~visitor.AddTapeArg

                tapeArgName="arg"+visitor.getNumArgs;
                tapeHeadName="arg"+visitor.getNumArgs;
                visitor.ArgTapeName=tapeArgName;
                visitor.ArgTapeHeadName=tapeHeadName;
                visitor.AddTapeArg=true;
            else

                tapeArgName=visitor.ArgTapeName;
                tapeHeadName=visitor.ArgTapeHeadName;
            end
            tapeArg=forLoopTape(forLoopWriteToArgTape);
            saveToArgTape="";
            for i=1:numSavedToArgTape
                saveToArgTape=saveToArgTape+...
                tapeArgName+"{"+tapeHeadName+"+"+i+"} = "+...
                tapeArg{i}+";"+newline;
            end
            saveToArgTape=saveToArgTape+...
            tapeHeadName+" = "+tapeHeadName+" + "+numSavedToArgTape+";"+newline;
            forloopBody=forloopBody+saveToArgTape;
        end


        totalSavedToArgTape=nIter*visitor.ArgTapeTotalElem+nIter*numSavedToArgTape;
        visitor.ArgTapeTotalElem=prevArgTapeNElem+totalSavedToArgTape;
    end
    forloopBody=strjoin("    "+splitlines(strip(forloopBody,'right')),'\n')+newline;
    forloopBody=...
    "for "+loopVarName+" = "+loopValuesStr+newline+...
    forloopBody+...
    "end"+newline;

    visitor.ExprBody=prevBody+forloopBody;

    isOuterLoop=LoopWrapper.LoopLevel==1;
    if isOuterLoop&&isempty(visitor.ForLoopTape)

        visitor.Tape=[visitor.Tape,{nArg},{0}];
        visitor.WriteToArgTape=[visitor.WriteToArgTape,false,false];
    else



        visitor.Tape(prevTapeNelem+1:tapeNelem)=[];
        visitor.WriteToArgTape(prevTapeNelem+1:tapeNelem)=[];
        visitor.ForLoopTape=[visitor.ForLoopTape,forLoopTape,{nArg}];
        visitor.ForLoopWriteToArgTape=[visitor.ForLoopWriteToArgTape,forLoopWriteToArgTape,false];

        if isOuterLoop

            nForLoopTape=numel(visitor.ForLoopTape);
            visitor.Tape=[visitor.Tape,visitor.ForLoopTape,nForLoopTape];
            visitor.WriteToArgTape=[visitor.WriteToArgTape,visitor.ForLoopWriteToArgTape,false];
            visitor.ForLoopTape=[];
            visitor.ForLoopWriteToArgTape=logical.empty;
        end
    end

end

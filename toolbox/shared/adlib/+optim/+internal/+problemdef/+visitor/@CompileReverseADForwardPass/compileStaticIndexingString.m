function[indexingStr,indexingNumParens,indexIsArgOrVar,indexFixedVar,...
    indexDependsOnLoopVar]=compileStaticIndexingString(visitor,Op,addParens)












    prevTape=visitor.Tape;
    prevWriteToArgTape=visitor.WriteToArgTape;

    index=Op.Index;
    Nindex=numel(index);
    if Nindex==1&&strcmp(index,':')

        indexingStr=':';
        indexingNumParens=0;
        indexIsArgOrVar=false;
        indexFixedVar=true;
        indexDependsOnLoopVar=false;
    else


        optimIdx=Op.OptimIndex;
        colonIdx=Op.ColonIndex;
        leftSize=Op.LhsSize;

        indexStr=strings(Nindex,1);
        indexingNumParens=addParens;
        indexFixedVar=true;
        indexDependsOnLoopVar=false;
        indexIsArgOrVar=false;



        head=visitor.Head;
        oldParentHead=visitor.ParentHead;
        visitor.ParentHead=head+1;
        if Nindex==1
            endIndexVal=prod(Op.LhsSize);
        else
            endIndexVal=Op.LhsSize;
        end
        for i=1:Nindex
            idx=index{i};
            if optimIdx(i)


                numParens=0;
                isArgOrVar=false;
                isAllZero=false;
                singleLine=true;
                push(visitor,string(endIndexVal(i)),numParens,isArgOrVar,isAllZero,singleLine);

                acceptVisitor(idx,visitor);


                [indexStr(i),thisParens,indexIsArgOrVar]=getArgumentName(visitor,indexingNumParens);
                indexFixedVar=indexFixedVar&&isFixedVar(visitor,head+2);
                indexDependsOnLoopVar=indexDependsOnLoopVar||dependsOnLoopVar(visitor,head+2);
                visitor.Head=head;
                indexingNumParens=indexingNumParens+thisParens;
            elseif colonIdx(i)

                indexStr(i)="1:"+leftSize(i);
            else

                visitIndexingVector(visitor,idx);
                [indexStr(i),thisParens]=getArgumentName(visitor,indexingNumParens);
                visitor.Head=head;
                indexingNumParens=indexingNumParens+thisParens;
            end
        end

        visitor.ParentHead=oldParentHead;

        indexingStr=strjoin(indexStr,',');
        indexingNumParens=indexingNumParens-addParens;
    end


    visitor.Tape=prevTape;
    visitor.WriteToArgTape=prevWriteToArgTape;
end

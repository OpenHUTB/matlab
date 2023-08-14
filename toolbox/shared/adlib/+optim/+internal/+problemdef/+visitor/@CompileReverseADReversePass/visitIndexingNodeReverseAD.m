function visitIndexingNodeReverseAD(visitor,visitTreeReverseAD,...
    forestSize,nTrees,treeList,forestIndexList,treeIndexList)






    dosubsasgn=visitor.doSubsasgn(nTrees,forestIndexList,forestSize);
    forestIdxStr="";
    forestIdxParens=0;




    addParens=Inf;
    [jacStr,jacNumParens,~,jacIsAllZero]=getParentJacArgumentName(visitor,addParens);



    for i=nTrees:-1:1

        treei=treeList{i};



        forestIndex=forestIndexList{i};






        treeIndex=treeIndexList{i};


        forestFcnBody="";



        if dosubsasgn


            forestIdxStr=getForwardMemory(visitor);
            forestIdxParens=getForwardMemory(visitor);
            forestIdxStr="("+forestIdxStr+",:)";
            forestIdxParens=forestIdxParens+1;
        end


        dosubsref=visitor.doSubsref(treeIndex,size(treei));



        if~dosubsref


            treeJacStr=jacStr+forestIdxStr;
            jacNumParens=jacNumParens+forestIdxParens;
            jacIsArgOrVar=~dosubsasgn;
        else


            treeIdxStr=getForwardMemory(visitor);
            getForwardMemory(visitor);







            treeIdxStr="("+treeIdxStr+",:)";



            treeJacStr="arg"+visitor.getNumArgs();
            jacNumParens=0;
            jacIsArgOrVar=true;


            forestFcnBody=forestFcnBody+treeJacStr+...
            " = sparse("+numel(treei)+","+visitor.NumExpr+");"+newline;


            if~jacIsAllZero









                [treeID,~,treeIdxG]=unique(treeIndex);

                if isequal(numel(treeIdxG),numel(treeID))

                    forestFcnBody=forestFcnBody+treeJacStr+treeIdxStr+" = "+jacStr+forestIdxStr+";"+newline;
                else


                    for ntree=1:length(treeID)


                        thisTreesForestIdx=forestIndex(treeIdxG==ntree);



                        treeIdxStr="("+compileIndexingString(visitor,treeID(ntree))+",:)";
                        forestIdxStr="("+compileIndexingString(visitor,thisTreesForestIdx)+",:)";
                        forestFcnBody=forestFcnBody+treeJacStr+treeIdxStr+" = "+...
                        " sum("+jacStr+forestIdxStr+", 1);"+newline;
                    end
                end
            end
        end


        visitor.ExprBody=visitor.ExprBody+forestFcnBody;


        visitTreeReverseAD(visitor,treei,i,treeJacStr,jacNumParens,jacIsArgOrVar,jacIsAllZero);
    end

end

function visitIndexingNode(visitor,visitTreeFun,forestSize,...
    nTrees,treeList,forestIndexList,treeIndexList)










    totalVar=visitor.TotalVar;


    nElem=prod(forestSize);
    bval=zeros(nElem,1);

    HIdx=[];
    HJdx=[];
    HVal=[];

    AIdx=[];
    AJdx=[];
    AVal=[];
    curAnnz=0;



    for i=1:nTrees

        treei=treeList{i};



        treeHeadIdx=visitTreeFun(visitor,treei,i);
        [bi,Ai,Hi]=popChild(visitor,treeHeadIdx);






        treeIndex=treeIndexList{i}(:)';



        forestIndex=forestIndexList{i}(:)';

        if ischar(forestIndex)
            forestIndex=1:numel(treei);
        else


            [forestIndex,keepIdx]=unique(forestIndex,'last');
            treeIndex=treeIndex(keepIdx);
        end


        if nnz(Hi)>0

            [HiIdx,HiJdx,HiVal]=find(Hi);
            HiIdx=HiIdx';
            HiJdx=HiJdx';
            HiVal=HiVal';




            rowShift=(forestIndex-treeIndex)*totalVar;


            [treeID,~,treeIdxG]=unique(treeIndex);



            treeRowIdx=(treeID-1)*totalVar;


            for k=1:length(treeID)



                forestIndexForTreek=find(treeIdxG==k);
                numForestIdxForTreek=numel(forestIndexForTreek);


                startIdx=treeRowIdx(k)+1;
                endIdx=treeRowIdx(k)+totalVar;


                thisIdx=(HiIdx>=startIdx)&(HiIdx<=endIdx);
                if any(thisIdx)
                    thisRowIdx=HiIdx(thisIdx);


                    thisRowIdx=thisRowIdx'+rowShift(forestIndexForTreek);


                    HIdx=[HIdx,thisRowIdx(:)'];%#ok<AGROW>
                    HJdx=[HJdx,repmat(HiJdx(thisIdx),1,numForestIdxForTreek)];%#ok<AGROW>
                    HVal=[HVal,repmat(HiVal(thisIdx),1,numForestIdxForTreek)];%#ok<AGROW>
                end
            end
        end


        if nnz(Ai)>0

            Ai=Ai(:,treeIndex);

            Ainnz=nnz(Ai);
            [AiIdx,AiJdx,AiVal]=find(Ai);

            AIdx(curAnnz+1:curAnnz+Ainnz)=AiIdx;
            AJdx(curAnnz+1:curAnnz+Ainnz)=forestIndex(AiJdx);
            AVal(curAnnz+1:curAnnz+Ainnz)=AiVal;
            curAnnz=curAnnz+Ainnz;
        end


        bval(forestIndex)=bi(treeIndex);

    end

    if numel(HVal)>0
        Hval=sparse(HIdx,HJdx,HVal,totalVar*nElem,totalVar);
    else
        Hval=[];
    end
    if numel(AVal)>0
        Aval=sparse(AIdx,AJdx,AVal,totalVar,nElem);
    else
        Aval=[];
    end


    push(visitor,Aval,bval);
    pushH(visitor,Hval);
end

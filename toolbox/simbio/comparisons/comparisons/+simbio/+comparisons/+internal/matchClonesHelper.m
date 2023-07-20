function[cloneOrder1,cloneOrder2]=matchClonesHelper(positions1,expressions,...
    positions2,matchedExpressions)



























    numBlocks1=numel(positions1);
    numBlocks2=numel(positions2);


    if~isempty(positions1)
        positions1=vertcat(positions1.Value);
    end
    if~isempty(positions2)
        positions2=vertcat(positions2.Value);
    end


    if~isempty(expressions)
        expressions={expressions.Value}';
    end


    cloneOrder1=nan(numBlocks1,1);
    cloneOrder2=nan(numBlocks2,1);

    matchCount=0;

    distances=nan(numBlocks1,numBlocks2);



    for iSourceBlock=1:numBlocks1
        for iTargetBlock=1:numBlocks2
            if~isempty(expressions{iSourceBlock})&&...
                ~isempty(matchedExpressions{iTargetBlock})&&...
                numel(expressions{iSourceBlock})==...
                numel(matchedExpressions{iTargetBlock})&&...
                all(ismember(expressions{iSourceBlock},matchedExpressions{iTargetBlock}))





                matchCount=matchCount+1;
                cloneOrder1(matchCount)=iSourceBlock;
                cloneOrder2(matchCount)=iTargetBlock;


                distances(iSourceBlock,:)=inf;
                distances(:,iTargetBlock)=inf;
                break;
            else


                distances(iSourceBlock,iTargetBlock)=...
                norm(abs(positions1(iSourceBlock,1:2)-positions2(iTargetBlock,1:2)));
            end
        end
    end


    for iSourceBlock=1:min(numBlocks1-matchCount,numBlocks2-matchCount)
        [~,idx]=min(distances,[],"all");
        [minSourceIdx,minTargetIdx]=ind2sub([numBlocks1,numBlocks2],idx);
        matchCount=matchCount+1;
        cloneOrder1(matchCount)=minSourceIdx;
        cloneOrder2(matchCount)=minTargetIdx;
        distances(minSourceIdx,:)=inf;
        distances(:,minTargetIdx)=inf;
    end



    matchCount=matchCount+1;
    nonMatchedPositionIdx=setdiff(1:numBlocks1,cloneOrder1(1:(matchCount-1)));
    if~isempty(nonMatchedPositionIdx)
        cloneOrder1(matchCount:numBlocks1)=nonMatchedPositionIdx;
    end
    nonMatchedPositionIdx=setdiff(1:numBlocks2,cloneOrder2(1:(matchCount-1)));
    if~isempty(nonMatchedPositionIdx)
        cloneOrder2(matchCount:numBlocks2)=nonMatchedPositionIdx;
    end

end
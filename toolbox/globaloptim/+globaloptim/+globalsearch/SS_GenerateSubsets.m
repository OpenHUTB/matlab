function SubsetList=SS_GenerateSubsets(RefSet,state)




















    SubsetList=[];
    switch state.IntensifyStage
    case 0
        [xx,yy]=meshgrid(1:RefSet.size,1:RefSet.size);
        xx=triu(xx,1);
        SubsetList=[xx(:),yy(:)];
        SubsetList=SubsetList(logical(SubsetList(:,1)),:);
        idxNEWFLAG=find(RefSet.combinationRecord);
        idx=any(ismember(SubsetList,idxNEWFLAG),2);
        SubsetList=SubsetList(idx,:);
    case 1
        a=1;
        SubsetFound=false;
        while a<=RefSet.size&&SubsetFound==false
            b=a+1;
            while b<=RefSet.size&&SubsetFound==false

                if RefSet.combinationRecord(a)||RefSet.combinationRecord(b)
                    SubsetList=[a,b];
                    SubsetFound=true;
                end
                b=b+1;
            end
            a=a+1;
        end
    case 2
        SubsetList=[1,2];
    end
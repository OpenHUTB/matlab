classdef TvbpZOES1D<FunctionApproximation.internal.gridcreator.QuantizedExplicitValues








    properties(Constant)
        MaxWordLength=20;
    end

    properties(SetAccess=private)
        GridMapper=FunctionApproximation.internal.gridcreator.GridToGridMapper();
        SearchVector=[];
        EvaluationGrid=[];
    end

    properties(Hidden)
        MaxPoints=2^9;
    end

    methods
        function this=TvbpZOES1D(dataTypes)
            this=this@FunctionApproximation.internal.gridcreator.QuantizedExplicitValues(dataTypes);
        end

        function grid=getGrid(this,rangeObject,~)







            bpCandidates=getSearchVector(this,rangeObject);






            nEvaluationGrid=2^(min(this.InputTypes.WordLength,this.MaxWordLength))-2;



            if nEvaluationGrid<=1000
                nEvaluationGrid=nEvaluationGrid+2;
            end


            gridStrat=FunctionApproximation.internal.gridcreator.QuantizedEvenSpacingCartesianGrid(this.InputTypes);
            evaluationGrid=gridStrat.getGrid(rangeObject,nEvaluationGrid);
            bpCandidatesNum=numel(bpCandidates);




            tp=evaluationGrid{1}(:);

            fhValue=this.ErrorFunction.Original.evaluate(tp);
            tighteningFactor=this.AcceptableTolerance/this.Options.AbsTol;
            errorBound=tighteningFactor*max(this.Options.AbsTol,this.Options.RelTol*abs(fhValue));







            currentBpLeftMostKnownIndex=bpCandidatesNum+1;




            currentTpLeftMostKnownIndex=numel(tp);
            bpindices=zeros(bpCandidatesNum,1);
            count=1;
            maxSegmentTree=FunctionApproximation.internal.utilities.ZKWSegmentTree(fhValue-errorBound);
            minSegmentTree=FunctionApproximation.internal.utilities.ZKWSegmentTree(-fhValue-errorBound);

            isFirstBpReached=false;



            while(~isFirstBpReached)

                [nextBpLeftMostKnownIndex,isFirstBpReached,nextTpLeftMostKnownIndex]=binarySearchTvbpZOES(this,...
                currentTpLeftMostKnownIndex,bpCandidates,tp,currentBpLeftMostKnownIndex,maxSegmentTree,minSegmentTree);

                bpindices(count)=nextBpLeftMostKnownIndex;
                currentTpLeftMostKnownIndex=nextTpLeftMostKnownIndex;
                currentBpLeftMostKnownIndex=nextBpLeftMostKnownIndex;
                count=count+1;
            end
            bpindices(count:end)=[];


            bpPositions=bpCandidates(flip(bpindices));



            if numel(bpPositions)<=1
                bpPositions=[bpCandidates(1),bpCandidates(end)];
            end
            grid{1}=bpPositions;
        end

    end

    methods(Access=protected)
        function searchVector=getSearchVector(this,rangeObject)
            gridStrat=FunctionApproximation.internal.gridcreator.QuantizedEvenSpacingCartesianGrid(this.DataTypes(1));
            for ii=1:this.DataTypes(1).WordLength
                searchVectorCell=getGrid(gridStrat,rangeObject,1+2^ii);
                searchVector=searchVectorCell{1};
                if numel(searchVector)>this.MaxPoints
                    break;
                end
            end
        end

    end

    methods(Access=private)
        function[newBpLeftMostKnownIndex,isFirstBpReached,newTpLeftMostKnownIndex]=binarySearchTvbpZOES(this,...
            oldTpLeftMostKnownIndex,bpCandidates,tp,OldBpLeftMostKnownIndex,maxSegmentTree,minSegmentTree)

            lowIndex=1;
            highIndex=OldBpLeftMostKnownIndex-1;
            isFirstBpReached=false;
            currentIndex=ceil((lowIndex+highIndex)/2);
            currentBp=bpCandidates(currentIndex);
            currentTpLeftMostKnownIndex=this.getLargestIndex(currentBp,tp);

            tvDataType=this.ErrorFunction.Approximation.Data.StorageTypes(2);
            tableValueUnquantized=Inf;
            halvedEsp=tvDataType.Slope/2;

            while(currentIndex<highIndex)
                if(currentTpLeftMostKnownIndex<0)||(oldTpLeftMostKnownIndex<currentTpLeftMostKnownIndex+1)
                    costUnquantized=-Inf;
                else
                    hBar=maxSegmentTree.query(currentTpLeftMostKnownIndex+1,oldTpLeftMostKnownIndex);
                    hUnderline=-minSegmentTree.query(currentTpLeftMostKnownIndex+1,oldTpLeftMostKnownIndex);
                    tableValueUnquantized=(hBar+hUnderline)/2;
                    costUnquantized=max(hBar-tableValueUnquantized,tableValueUnquantized-hUnderline);
                end

                if costUnquantized>0
                    lowIndex=currentIndex;
                elseif costUnquantized+halvedEsp<0
                    highIndex=currentIndex;
                else
                    if tvDataType.ishalf
                        tvQuantized=double(half(tableValueUnquantized));
                    else
                        tvQuantized=double(fi(tableValueUnquantized,tvDataType));
                    end

                    costQuantized=max(hBar-tvQuantized,tvQuantized-hUnderline);
                    if costQuantized>0
                        lowIndex=currentIndex;
                    else
                        highIndex=currentIndex;
                    end
                end

                currentIndex=ceil((lowIndex+highIndex)/2);
                currentBp=bpCandidates(currentIndex);
                currentTpLeftMostKnownIndex=this.getLargestIndex(currentBp,tp);

            end

            newBpLeftMostKnownIndex=currentIndex;

            currentTpLeftMostKnownIndex=this.getLargestIndex(bpCandidates(currentIndex),tp);
            newTpLeftMostKnownIndex=currentTpLeftMostKnownIndex;

            if currentTpLeftMostKnownIndex<0
                isFirstBpReached=true;
                return;
            end

            hBar=maxSegmentTree.query(1,currentTpLeftMostKnownIndex);
            hUnderline=-minSegmentTree.query(1,currentTpLeftMostKnownIndex);
            costUnquantized=max(hBar-tableValueUnquantized,tableValueUnquantized-hUnderline);

            if costUnquantized>0
                return;
            end

            if costUnquantized+halvedEsp<0
                isFirstBpReached=true;
                return
            end

            if tvDataType.ishalf
                tvQuantized=double(half(tableValueUnquantized));
            else
                tvQuantized=double(fi(tableValueUnquantized,tvDataType));
            end

            costQuantized=max(hBar-tvQuantized,tvQuantized-hUnderline);

            if costQuantized<=0
                isFirstBpReached=true;
            end

        end

        function maxIndex=getLargestIndex(~,target,nums)




            maxIndex=-1;%#ok<NASGU> 

            if isempty(nums)||target<=nums(1)
                maxIndex=-1;
                return
            end

            left=1;
            right=numel(nums);
            while left+1<right
                mid=bitshift(left+right,-1);
                if nums(mid)<target
                    left=mid;
                else
                    right=mid;
                end
            end

            if nums(right)<target
                maxIndex=right;
                return
            end

            maxIndex=left;
            return
        end
    end
end



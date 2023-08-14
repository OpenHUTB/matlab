function RefSet=SS_UpdateReferenceSet(RefSet,Combinations,options,state)



















    if strcmpi(options.RefSetType,'tiered')
        b1=ceil(options.RefSetSize*options.GoodFraction);
    else
        b1=options.RefSetSize;
    end


    [Combinations,~,CombScore]=globaloptim.globalsearch.SS_SortPoints(Combinations,state);


    RefSetScore=globaloptim.globalsearch.SS_CalculateScore(RefSet.points,RefSet.functionVals,...
    RefSet.conVals,RefSet.conEqVals,state);



    for CombinationIndex=1:Combinations.size


        if isnan(Combinations.functionVals(CombinationIndex))
            continue;
        end


        nans=find(isnan(RefSet.functionVals));
        if~isempty(nans)
            WorstVal=nan;
            WorstIndex=nans(1);
        else

            [WorstVal,WorstIndex]=max(RefSetScore(1:b1));
        end

        if CombScore(CombinationIndex)<WorstVal||isnan(WorstVal)
            RefSetScore(WorstIndex)=CombScore(CombinationIndex);


            indLastAddedCombination=CombinationIndex;
            if~isempty(RefSet.conVals)
                RefSet.conVals(WorstIndex,:)=Combinations.conVals(CombinationIndex,:);
            end
            if~isempty(RefSet.conEqVals)
                RefSet.conEqVals(WorstIndex,:)=Combinations.conEqVals(CombinationIndex,:);
            end
            RefSet.points(WorstIndex,:)=Combinations.points(CombinationIndex,:);
            RefSet.functionVals(WorstIndex)=Combinations.functionVals(CombinationIndex);


            RefSet.combinationRecord(WorstIndex)=true;
        else

            indLastAddedCombination=CombinationIndex-1;



            break
        end
    end
    if strcmpi(options.RefSetType,'tiered')&&b1<options.RefSetSize


        if CombinationIndex>1
            idxKeep=indLastAddedCombination+1:Combinations.size;
            Combinations.points=Combinations.points(idxKeep,:);
            Combinations.functionVals=Combinations.functionVals(idxKeep);
            if~isempty(Combinations.conVals)
                Combinations.conVals=Combinations.conVals(idxKeep,:);
            end
            if~isempty(Combinations.conEqVals)
                Combinations.conEqVals=Combinations.conEqVals(idxKeep,:);
            end
            Combinations.size=size(Combinations.points,1);
            CombScore=CombScore(idxKeep);
        end


        for counter=(b1+1):options.RefSetSize

            RefSetDistance=options.DistanceMeasureFcn...
            (RefSet.points,counter-1,...
            RefSet.points(counter:end,:),1);
            [~,RefSetIndex]=max(RefSetDistance);

            RefSetIndex=RefSetIndex+counter-1;


            if isnan(RefSetScore(RefSetIndex))
                ToConsider=1:length(Combinations.functionVals);
            else
                ToConsider=find(CombScore<RefSetScore(RefSetIndex));
            end

            if isempty(ToConsider)


                continue
            else

                CombinationsDistances=options.DistanceMeasureFcn...
                (RefSet.points,RefSetIndex-1,...
                Combinations.points(ToConsider,:),length(ToConsider));



                [~,CombinationIndex]=max(CombinationsDistances);
                CombinationIndex=ToConsider(CombinationIndex);


                RefSet.points(RefSetIndex,:)=Combinations.points(CombinationIndex,:);
                RefSet.functionVals(RefSetIndex)=...
                Combinations.functionVals(CombinationIndex);
                if~isempty(Combinations.conVals)
                    RefSet.conVals(RefSetIndex,:)=...
                    Combinations.conVals(CombinationIndex,:);
                end
                if~isempty(Combinations.conEqVals)
                    RefSet.conEqVals(RefSetIndex,:)=...
                    Combinations.conEqVals(CombinationIndex,:);
                end
                RefSet.combinationRecord(RefSetIndex)=true;




                Combinations.points(CombinationIndex,:)=[];
                Combinations.functionVals(CombinationIndex)=[];
                if~isempty(Combinations.conVals)
                    Combinations.conVals(CombinationIndex,:)=[];
                end
                if~isempty(Combinations.conEqVals)
                    Combinations.conEqVals(CombinationIndex,:)=[];
                end
                Combinations.size=Combinations.size-1;
                CombScore(CombinationIndex)=[];
            end
        end
    end


    RefSet=globaloptim.globalsearch.SS_SortPoints(RefSet,state);

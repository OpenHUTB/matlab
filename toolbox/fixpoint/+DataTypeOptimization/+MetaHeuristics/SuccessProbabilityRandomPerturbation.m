classdef SuccessProbabilityRandomPerturbation<DataTypeOptimization.MetaHeuristics.RandomPerturbation








    properties(SetAccess=protected)
successProbabilities
probabilityThreshold
memberIndices
    end

    methods
        function this=SuccessProbabilityRandomPerturbation(perturbationMinMax,perturbationMembersMax,numMembers,solutionsRepo,probabilityThreshold)

            this@DataTypeOptimization.MetaHeuristics.RandomPerturbation(perturbationMinMax,perturbationMembersMax,numMembers);


            this.successProbabilities=1-this.getMeanFailureProbabilities(solutionsRepo.solutions.values);


            this.probabilityThreshold=probabilityThreshold;


            [sortedProbabilities,this.memberIndices]=sort(this.successProbabilities,'descend');
            this.memberIndices(sortedProbabilities<this.probabilityThreshold)='';
        end

    end

    methods(Hidden)
        function memberIndex=getMemberIndices(this)
            if isempty(this.memberIndices)



                memberIndex=getMemberIndices@DataTypeOptimization.MetaHeuristics.RandomPerturbation(this);
            else
                memberIndex=this.memberIndices;


                if length(this.memberIndices)>this.perturbationMembersMax
                    memberIndex(this.perturbationMembersMax+1:end)='';
                end
            end
        end

        function probabilities=getMeanFailureProbabilities(~,allSolutions)

            allSolutions=[allSolutions{:}];


            validSolutionsIndex=false(numel(allSolutions),1);
            for sIndex=1:numel(allSolutions)
                validSolutionsIndex(sIndex)=allSolutions(sIndex).isValid;
            end
            allSolutions(~validSolutionsIndex)='';


            allDefinitionDomainIndices=zeros(numel(allSolutions),numel(allSolutions(1).definitionDomainIndex));
            for sIndex=1:numel(allSolutions)
                allDefinitionDomainIndices(sIndex,:)=allSolutions(sIndex).definitionDomainIndex;
            end


            allPass=[allSolutions.Pass];

            for dvIndex=1:size(allDefinitionDomainIndices,2)
                uniqueDomain=unique(allDefinitionDomainIndices(:,dvIndex));
                for dIndex=1:length(uniqueDomain)
                    currentIndex=allDefinitionDomainIndices(:,dvIndex)==uniqueDomain(dIndex);
                    currentPass=allPass(currentIndex);
                    probabilities(dvIndex,dIndex)=1-mean(currentPass);%#ok<AGROW>
                end
                probabilities(dvIndex,:)=probabilities(dvIndex,:)/max(probabilities(dvIndex,:));
            end


            cToRemove=[];
            for cIndex=1:size(probabilities,2)
                if all(probabilities(:,cIndex)==1)||all(probabilities(:,cIndex)==0)
                    cToRemove(end+1)=cIndex;%#ok<AGROW>
                end
            end


            probabilities(:,cToRemove)='';
            probabilities=mean(probabilities,2);

        end
    end
end
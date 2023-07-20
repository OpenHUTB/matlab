classdef RandomPerturbation<handle






    properties(SetAccess=protected)
        solutionType=DataTypeOptimization.SolutionType.RandomPerturbation;
perturbationMinMax
perturbationMembersMax
totalNumberOfMembers

    end

    methods
        function this=RandomPerturbation(perturbationMinMax,perturbationMembersMax,numMembers)
            this.perturbationMinMax=perturbationMinMax;
            this.perturbationMembersMax=perturbationMembersMax;
            this.totalNumberOfMembers=numMembers;

        end

        function perturbationVector=getPerturbation(this)

            perturbationVector=zeros(1,this.totalNumberOfMembers);


            memberIndex=this.getMemberIndices();


            perturbMin=this.perturbationMinMax(1);
            perturbMax=this.perturbationMinMax(2);

            perturbationVector(memberIndex)=randi([perturbMin,perturbMax],1,length(memberIndex));

        end
    end

    methods(Hidden)
        function memberIndex=getMemberIndices(this)
            memberIndex=randperm(this.totalNumberOfMembers);
            memberIndex(this.perturbationMembersMax+1:end)='';
        end
    end
end
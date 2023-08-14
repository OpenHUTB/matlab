classdef SolutionRepository<handle




    properties(SetAccess=private,GetAccess=public)
solutions
bestSolution
    end

    properties(SetAccess=private,GetAccess=public,Hidden)
solutionMetaData
    end

    methods
        function this=SolutionRepository()
            this.solutions=containers.Map();
            this.solutionMetaData=containers.Map();
            this.bestSolution=this.getEmptySolution();

        end

        function solutionExist=solutionExists(this,newSolution)



            solutionExist=this.solutions.isKey(newSolution.id);
        end

        function addSolution(this,newSolution,solutionType)




            if~this.solutions.isKey(newSolution.id)

                this.solutions(newSolution.id)=newSolution;


                newMetaData=DataTypeOptimization.SolutionMetaData();
                newMetaData.type=solutionType;
                newMetaData.index=this.solutions.Count;


                this.solutionMetaData(newSolution.id)=newMetaData;


                this.updateBestSolution(newSolution);
            end
        end

        function updateBestSolution(this,newSolution)

            if newSolution.isValid
                if this.bestSolution.Pass
                    if newSolution.Pass
                        if this.bestSolution.Cost>newSolution.Cost
                            this.bestSolution=newSolution;
                        end
                    end
                else
                    if newSolution.Pass
                        this.bestSolution=newSolution;
                    else

                        if this.bestSolution.MaxDifference>newSolution.MaxDifference||...
                            isinf(this.bestSolution.MaxDifference)&&isinf(newSolution.MaxDifference)
                            this.bestSolution=newSolution;
                        end
                    end
                end
            end

        end

        function emptySolution=getEmptySolution(~)

            emptySolution=DataTypeOptimization.OptimizationSolution();
        end

        function clonedSolution=cloneSolution(this,originalSolution)


            clonedSolution=this.getEmptySolution();


            clonedSolution.definitionDomainIndex=originalSolution.definitionDomainIndex;
        end

        function bestSolution=getBestSolution(this)

            bestSolution=this.bestSolution;
        end

    end
end

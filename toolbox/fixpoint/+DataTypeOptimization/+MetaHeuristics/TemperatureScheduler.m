classdef TemperatureScheduler<handle









    properties(Constant)
        lambda=0.94;
        initialTemperature=3;

    end

    properties
currentBestSolution
temperature
solutionRepo
        iterationCount=1;
        resetCount=50;
    end

    methods
        function this=TemperatureScheduler(solutionRepo,resetCount)
            if nargin<2
                this.resetCount=50;
            else
                this.resetCount=resetCount;
            end

            this.initialize(solutionRepo);

        end

        function initialize(this,solutionRepo)

            this.solutionRepo=solutionRepo;



            this.currentBestSolution=this.solutionRepo.getBestSolution();


            this.temperature=this.initialTemperature;

        end

        function solution=getBestSolution(this)

            solution=this.currentBestSolution;

        end

        function addSolution(this,newSolution,newSolutionType)

            this.solutionRepo.addSolution(newSolution,newSolutionType);


            this.updateCurrentBestSolution(newSolution);

        end

        function solution=cloneSolution(this,solution)

            solution=this.solutionRepo.cloneSolution(solution);
        end

        function exist=solutionExists(this,solution)

            exist=this.solutionRepo.solutionExists(solution);
        end

        function updateCurrentBestSolution(this,newSolution)


            if~mod(this.iterationCount,this.resetCount)
                this.currentBestSolution=this.solutionRepo.getBestSolution();
                this.iterationCount=1;
            elseif rand<exp(-1/this.temperature)


                if newSolution.Pass
                    this.currentBestSolution=newSolution;
                end

            end


            this.updateTemperature();

        end

        function updateTemperature(this)

            this.temperature=this.initialTemperature*((this.lambda)^this.iterationCount);


            this.iterationCount=this.iterationCount+1;
        end

    end

end